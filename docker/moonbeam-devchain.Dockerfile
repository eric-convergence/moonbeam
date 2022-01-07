FROM ubuntu:22.04
RUN apt update
RUN apt install curl -y
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN apt-get install libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang make build-essential -y
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
# RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup component add rustfmt
RUN rustup update

COPY . /moonbeam

WORKDIR /moonbeam
RUN cargo build --release

FROM ubuntu:22.04

RUN useradd -m -u 1000 -U -s /bin/sh -d /moonbeam moonbeam
USER moonbeam

COPY --from=0 --chown=moonbeam /moonbeam/target/release/moonbeam /moonbeam/moonbeam
RUN chmod uog+x /moonbeam/moonbeam
EXPOSE 30333 30334 9933 9944 9615 

VOLUME ["/data"]
ENTRYPOINT ["/moonbeam/moonbeam"]
