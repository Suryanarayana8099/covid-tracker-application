FROM adoptopenjdk/openjdk11:alpine

WORKDIR /app

COPY target/covid-tracker-application-0.0.1-SNAPSHOT.jar /app/app.jar

#EXPOSE 4040

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
