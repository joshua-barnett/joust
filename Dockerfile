FROM debian:bullseye-slim@sha256:06a93cbdd49a265795ef7b24fe374fee670148a7973190fb798e43b3cf7c5d0f

RUN apt-get update \
&& apt-get install --yes \
autoconf \
automake \
bison \
flex \
gcc \
make

WORKDIR /usr/src

COPY asm6809 asm6809

WORKDIR /usr/src/asm6809

RUN ./autogen.sh
RUN ./configure
RUN make
RUN ln -s /usr/src/asm6809/src/asm6809 /usr/bin/asm6809
