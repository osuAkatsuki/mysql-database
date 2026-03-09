FROM ubuntu:24.04

WORKDIR /srv/root

RUN apt-get update && apt-get install -y --no-install-recommends \
    default-mysql-client \
    wget \
    ca-certificates \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/golang-migrate/migrate/releases/download/v4.15.2/migrate.linux-amd64.tar.gz && \
    tar zxvf migrate.linux-amd64.tar.gz && \
    mv migrate /usr/local/bin/go-migrate && \
    chmod u+x /usr/local/bin/go-migrate && \
    rm migrate.linux-amd64.tar.gz

COPY . .

ENTRYPOINT [ "scripts/entrypoint.sh" ]
