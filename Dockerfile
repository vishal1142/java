# Safer alternative using Eclipse Temurin
FROM eclipse-temurin:21-jdk-jammy
WORKDIR /app
COPY ./target/*.jar /app.jar
CMD ["java", "-jar", "app.jar"]