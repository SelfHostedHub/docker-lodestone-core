FROM rust as build

ENV LODESTONE-CORE-VERSION=v0.4.2
# create and enter app directory
WORKDIR /app

WORKDIR /
# copy over project files
RUN wget https://github.com/Lodestone-Team/lodestone_core/archive/refs/tags/${LODESTONE-CORE-VERSION}.zip \
    && unzip ${ROADMAPVERSION}.zip \
    && mv roadmap-${ROADMAPVERSION}/* /app \
    && chmod +x /app

WORKDIR /app
# build app using 'release' profile
RUN cargo build --release

FROM debian:bullseye-slim as production

#
RUN apt-get update \
  && apt-get install -y ca-certificates \
  && update-ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# create and enter app directory
WORKDIR /app

# copy over built app
COPY --from=build /app/target/release/main ./

# specify default port
EXPOSE 16662

# specify persistent volume
VOLUME ["/root/.lodestone"]

# start lodestone_core
CMD ["./main"]