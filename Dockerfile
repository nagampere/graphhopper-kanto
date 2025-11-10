FROM maven:3.9.5-eclipse-temurin-21 as build

# Install curl
RUN apt-get update && apt-get install -y curl
# Install git
RUN apt-get install -y git
RUN git clone https://github.com/graphhopper/graphhopper.git

WORKDIR /graphhopper
# COPY graphhopper .

# Copy custom model files
COPY custom_models/car-japan.json ./core/src/main/resources/com/graphhopper/custom_models/
COPY custom_models/bike-japan.json ./core/src/main/resources/com/graphhopper/custom_models/
COPY custom_models/foot-japan.json ./core/src/main/resources/com/graphhopper/custom_models/

RUN mvn clean install -DskipTests

FROM eclipse-temurin:21-jre

ARG REGION
ENV REGION=${REGION}
ARG JAVA_OPTS
ENV JAVA_OPTS=${JAVA_OPTS}

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
