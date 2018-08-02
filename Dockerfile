FROM bitwalker/alpine-elixir-phoenix:latest

RUN curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-17.03.1-ce.tgz && tar --strip-components=1 -xvzf docker-17.03.1-ce.tgz -C /usr/local/bin


# Set exposed ports
EXPOSE 4545
ENV PORT=4545 MIX_ENV=dev
ENV TEST_DB=db

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

ENV MIX_ENV=test
RUN mix do deps.get, deps.compile
# RUN chown default:root ./_build
# RUN chown default:root ./deps
ENV MIX_ENV=dev

# Same with npm deps
RUN mix deps.get
ADD assets/package.json assets/
RUN cd assets && \
    npm install

ADD . .

RUN cd assets/ && \
    npm run deploy && \
    cd - && \
    mix do deps.get, deps.compile, phx.digest

RUN mix deps.get

CMD ["mix", "phx.server"]
