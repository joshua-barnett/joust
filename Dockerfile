FROM alpine:3.17.3@sha256:124c7d2707904eea7431fffe91522a01e5a861a624ee31d03372cc1d138a3126 AS base

FROM base AS asm6809

RUN apk add --no-cache \
autoconf \
automake \
byacc \
curl \
flex \
gcc \
make \
musl-dev

WORKDIR /usr/src/asm6809

COPY asm6809 .

RUN ./autogen.sh \
&& ./configure \
&& make

RUN ln -s /usr/src/asm6809/src/asm6809 /usr/local/bin/asm6809

FROM base AS env

RUN apk add --no-cache \
curl \
make \
nodejs \
zip

COPY --from=asm6809 /usr/src/asm6809/src/asm6809 /usr/local/bin/asm6809
