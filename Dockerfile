FROM rust as build

ENV LODESTONECOREVERSION=v0.4.2
ENV LODESTONECOREZIP=0.4.2

WORKDIR /app
# copy over project files
RUN wget https://github.com/Lodestone-Team/lodestone_core/archive/refs/tags/${LODESTONECOREVERSION}.zip \
    && unzip ${LODESTONECOREVERSION}.zip \
    && mv lodestone_core-${LODESTONECOREZIP}/* ./ 

# build app using 'release' profile

RUN cargo build --release

FROM debian:bullseye-slim as production


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