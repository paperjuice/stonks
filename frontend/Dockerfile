FROM nginx as app_builder

MAINTAINER Dragos Dumitru

WORKDIR /opt/stonks_fe

COPY . /opt/stonks_fe

RUN curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz && \
    gunzip elm.gz && \
    chmod +x elm && \
    mv elm /usr/local/bin/ && \
    elm make src/Main.elm --output=static/index.html

FROM nginx

WORKDIR /opt/stonks_fe

COPY --from=app_builder /opt/stonks_fe/static /usr/share/nginx/html
