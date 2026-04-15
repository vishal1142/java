param(
    [string]$EnvFile = (Join-Path (Resolve-Path "$PSScriptRoot/..") "secrets.env"),
    [string]$MainRepoPath = (Resolve-Path "$PSScriptRoot/.."),
    [string]$LibraryRepoPath = (Join-Path (Resolve-Path "$PSScriptRoot/..") "Jenkins library"),
    [string]$MainBranch = "main",
    [string]$LibraryBranch = "master",
    [string]$BuildAction = "create",
    [switch]$AllowDirtyMainRepo,
    [switch]$SkipBuildTrigger
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Load-DotEnv {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        throw "Env file not found: $Path"
    }

    Get-Content $Path | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith("#") -or -not $line.Contains("=")) {
            return
        }
        $parts = $line.Split("=", 2)
        $key = $parts[0].Trim()
        $value = $parts[1].Trim().Trim("'").Trim('"')
        if ($key) {
            Set-Item -Path "Env:$key" -Value $value
        }
    }
}

function Get-RequiredEnv {
    param([string]$Name)
    $envItem = Get-Item -Path "Env:$Name" -ErrorAction SilentlyContinue
    $value = if ($null -ne $envItem) { $envItem.Value } else { $null }
    if (-not $value) {
        throw "Missing required environment variable: $Name"
    }
    return $value
}

function Get-OptionalEnv {
    param(
        [string]$Name,
        [string]$Default = ""
    )
    $envItem = Get-Item -Path "Env:$Name" -ErrorAction SilentlyContinue
    $value = if ($null -ne $envItem) { $envItem.Value } else { $null }
    if ($null -eq $value -or $value -eq "") {
        return $Default
    }
    return $value
}

function Assert-CleanTree {
    param([string]$RepoPath)
    Push-Location $RepoPath
    try {
        $dirty = git status --porcelain
        if ($LASTEXITCODE -ne 0) {
            throw "Unable to check git status in $RepoPath"
        }
        if ($dirty) {
            throw "Working tree has uncommitted changes in '$RepoPath'. Commit/stash first."
        }
    }
    finally {
        Pop-Location
    }
}

function Get-AheadCount {
    param(
        [string]$RepoPath,
        [string]$Branch
    )
    Push-Location $RepoPath
    try {
        $countText = git rev-list --count "origin/$Branch..HEAD" 2>$null
        if ($LASTEXITCODE -ne 0) {
            return 0
        }
        return [int]$countText.Trim()
    }
    finally {
        Pop-Location
    }
}

function Push-WithPat {
    param(
        [string]$RepoPath,
        [string]$Branch,
        [string]$GithubUser,
        [string]$GithubPat,
        [bool]$AllowDirty = $false
    )
    if (-not $AllowDirty) {
        Assert-CleanTree -RepoPath $RepoPath
    }

    $ahead = Get-AheadCount -RepoPath $RepoPath -Branch $Branch
    if ($ahead -le 0) {
        Write-Host "No commits to push in '$RepoPath' (branch '$Branch')."
        return
    }

    $basicAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$GithubUser`:$GithubPat"))
    Push-Location $RepoPath
    try {
        Write-Host "Pushing '$RepoPath' -> origin/$Branch ..."
        git -c "http.https://github.com/.extraheader=AUTHORIZATION: basic $basicAuth" push origin $Branch
        if ($LASTEXITCODE -ne 0) {
            throw "Push failed for '$RepoPath'."
        }
    }
    finally {
        Pop-Location
    }
}

function Trigger-JenkinsBuild {
    param(
        [string]$BaseUrl,
        [string]$User,
        [string]$Token,
        [string]$JobName,
        [string]$Action
    )
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $pair = "$User`:$Token"
    $auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))
    $baseHeaders = @{ Authorization = "Basic $auth" }

    $crumb = Invoke-RestMethod -Method Get -Uri "$BaseUrl/crumbIssuer/api/json" -Headers $baseHeaders -WebSession $session
    $headers = @{
        Authorization = "Basic $auth"
    }
    $headers[$crumb.crumbRequestField] = $crumb.crumb

    try {
        $uri = "$BaseUrl/job/$JobName/buildWithParameters?action=$Action"
        $resp = Invoke-WebRequest -Method Post -Uri $uri -Headers $headers -WebSession $session
        Write-Host "Triggered parameterized build: HTTP $($resp.StatusCode)"
    }
    catch {
        $message = $_.Exception.Message
        if ($message -match "not parameterized") {
            $fallbackUri = "$BaseUrl/job/$JobName/build"
            $resp = Invoke-WebRequest -Method Post -Uri $fallbackUri -Headers $headers -WebSession $session
            Write-Host "Job is not parameterized yet, triggered normal build: HTTP $($resp.StatusCode)"
        }
        else {
            throw
        }
    }
}

Load-DotEnv -Path $EnvFile

$githubUser = Get-RequiredEnv -Name "GITHUB_USERNAME"
$githubPat = Get-RequiredEnv -Name "GITHUB_PAT"

Push-WithPat -RepoPath $LibraryRepoPath -Branch $LibraryBranch -GithubUser $githubUser -GithubPat $githubPat
Push-WithPat -RepoPath $MainRepoPath -Branch $MainBranch -GithubUser $githubUser -GithubPat $githubPat -AllowDirty $AllowDirtyMainRepo.IsPresent

if (-not $SkipBuildTrigger) {
    $jenkinsUrl = Get-OptionalEnv -Name "JENKINS_URL" -Default "http://localhost:8080"
    $jenkinsUrl = $jenkinsUrl.TrimEnd("/")
    $jenkinsUser = Get-OptionalEnv -Name "JENKINS_USER" -Default "admin"
    $jenkinsToken = Get-OptionalEnv -Name "JENKINS_API_TOKEN"
    if (-not $jenkinsToken) {
        $jenkinsToken = Get-RequiredEnv -Name "JENKINS_PASSWORD"
    }
    $jobName = Get-OptionalEnv -Name "JENKINS_JOB_NAME" -Default "java-ci"

    Trigger-JenkinsBuild -BaseUrl $jenkinsUrl -User $jenkinsUser -Token $jenkinsToken -JobName $jobName -Action $BuildAction
}

Write-Host "Automation complete."
