FROM ubuntu:20.04

RUN apt update
RUN apt install -y git make wget sudo gpg xz-utils && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean

COPY . "/dotfiles"
WORKDIR "/dotfiles"

# docker build . -t system
# docker run -t -i system /bin/bash
