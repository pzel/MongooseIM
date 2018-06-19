# Build container for Debian Stretch .deb packages
FROM ubuntu:xenial

RUN apt-get update && \
    apt-get install -y wget gnupg &&\
     wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb &&\
    apt-get update &&\
    apt-get install -y git \
                       sudo \
                       make \
                       g++ \
                       libssl-dev \
                       libexpat-dev \
                       zlib1g-dev \
                       locales \
                       unixodbc-dev \
                       esl-erlang=1:19.3.6 &&\
     locale-gen en_US.UTF-8 &&\
    git clone https://github.com/pzel/mongooseim --depth=1 mim.git &&\
    (cd mim.git && ./tools/configure with-none && make rel) &&\
    mv mim.git/_build/prod/rel/mongooseim /mongooseim

COPY entrypoint.sh /
RUN  chmod +x /entrypoint.sh


