FROM maven:3.9.5-eclipse-temurin-21 as build

WORKDIR /graphhopper

COPY graphhopper .

RUN mvn clean install

FROM eclipse-temurin:21.0.1_12-jre

ENV JAVA_OPTS "-Xmx1g -Xms1g"

RUN mkdir -p /data

WORKDIR /graphhopper

COPY --from=build /graphhopper/web/target/graphhopper*.jar ./

COPY download.sh config-others.yml graphhopper.sh config-gh.yml ./

RUN chmod +x ./download.sh
RUN ./download.sh

# Enable connections from outside of the container
RUN sed -i '/^ *bind_host/s/^ */&# /p' config-gh.yml

VOLUME [ "/data" ]

EXPOSE 8989 8990

HEALTHCHECK --interval=5s --timeout=3s CMD curl --fail http://localhost:8989/health || exit 1

ENTRYPOINT [ "./graphhopper.sh", "-c", "config-gh.yml"] 
