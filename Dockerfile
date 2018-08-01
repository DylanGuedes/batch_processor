FROM bitwalker/alpine-elixir-phoenix:latest

RUN curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-17.03.1-ce.tgz && tar --strip-components=1 -xvzf docker-17.03.1-ce.tgz -C /usr/local/bin


# Set exposed ports
EXPOSE 4545
ENV PORT=4545 MIX_ENV=prod

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

ENV MIX_ENV=test
RUN mix do deps.get, deps.compile
RUN chown default:root ./_build
RUN chown default:root ./deps
ENV MIX_ENV=prod

# Same with npm deps
ADD assets/package.json assets/
RUN cd assets && \
    npm install

ADD . .

RUN cd assets/ && \
    npm run deploy && \
    cd - && \
    mix do compile, phx.digest

RUN mix ecto.create

CMD ["mix", "phx.server"]
