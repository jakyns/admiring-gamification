FROM elixir:1.10.3

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install --yes postgresql-client \
    && mkdir /app

WORKDIR /app

COPY . /app

RUN mix local.hex --force

EXPOSE 4000

CMD ["./build.sh"]
