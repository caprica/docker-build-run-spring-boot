FROM maven:3.8.5-eclipse-temurin-17 AS build
RUN mkdir /build
WORKDIR /build
COPY . .
#RUN --mount=type=cache,target=/root/.m2 mvn clean package -B -s ./settings.xml
RUN --mount=type=cache,target=/root/.m2 mvn clean package -B

FROM openjdk:17-alpine
ENV APP_USER=spring
RUN addgroup -S $APP_USER && adduser -S $APP_USER -G $APP_USER
RUN mkdir /app && chown -R $APP_USER:$APP_USER /app
USER $APP_USER
WORKDIR /app
COPY --from=build /build/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
