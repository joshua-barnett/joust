FROM alpine:3.17.3@sha256:124c7d2707904eea7431fffe91522a01e5a861a624ee31d03372cc1d138a3126 AS base

FROM base AS asm6809

RUN apk add --no-cache \
autoconf=2.71-r1 \
automake=1.16.5-r1 \
byacc=20221106-r0 \
curl=8.0.1-r0 \
flex=2.6.4-r3 \
gcc=12.2.1_git20220924-r4 \
make=4.3-r1 \
musl-dev=1.2.3-r4

WORKDIR /usr/src/asm6809

COPY asm6809 .

RUN ./autogen.sh \
&& ./configure \
&& make

RUN ln -s /usr/src/asm6809/src/asm6809 /usr/local/bin/asm6809

FROM base AS env

RUN apk add --no-cache \
curl=8.0.1-r0 \
make=4.3-r1 \
nodejs=18.14.2-r0 \
zip=3.0-r10

COPY --from=asm6809 /usr/src/asm6809/src/asm6809 /usr/local/bin/asm6809
