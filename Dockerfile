FROM ubuntu:23.10

WORKDIR /srv/root

RUN apt update && apt install -y default-mysql-client wget

RUN wget https://github.com/golang-migrate/migrate/releases/download/v4.15.2/migrate.linux-amd64.tar.gz && \
    tar zxvf migrate.linux-amd64.tar.gz && \
    mv migrate /usr/local/bin/go-migrate && \
    chmod u+x /usr/local/bin/go-migrate && \
    rm migrate.linux-amd64.tar.gz

COPY . .

ENTRYPOINT [ "scripts/entrypoint.sh" ]
