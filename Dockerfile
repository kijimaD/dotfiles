FROM ubuntu:20.04

RUN apt update
RUN apt install -y git make wget sudo gpg xz-utils && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean

COPY . /system
WORKDIR /system
RUN make ci

WORKDIR "/root/dotfiles"

# docker build . -t system
# docker run -v $(pwd):/root/dotfiles -i --rm -t system /bin/bash
