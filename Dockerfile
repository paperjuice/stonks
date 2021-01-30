FROM elixir:1.11-alpine as app_builder

MAINTAINER Dragos Dumitru

WORKDIR /opt/stonks

COPY . /opt/stonks

RUN apk update && \
    apk --no-cache add curl && \
    apk add --no-cache git openssh && \
    apk add bash && \
    apk add make && \
    apk add gcc && \
    apk add --no-cache ncurses-dev && \
    apk add libssl1.1 && \
    apk add --no-cache su-exec

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    MIX_ENV=prod mix release stonks --overwrite

FROM alpine:3.13

RUN apk update && \
    apk add --no-cache openssh && \
    apk add libssl1.1 && \
    apk add bash && \
    apk add --no-cache ncurses-dev

WORKDIR /opt/stonks
COPY --from=app_builder /opt/stonks/_build/prod/rel/stonks/ .

CMD ["/opt/stonks/bin/stonks", "start"]

