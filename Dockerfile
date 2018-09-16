FROM liuchong/rustup:stable

RUN apt update
RUN apt upgrade -y
RUN apt install libsqlite3-dev
USER root
RUN rustup default nightly
