FROM bitwalker/alpine-elixir-phoenix:1.7.0

RUN curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-17.03.1-ce.tgz && tar --strip-components=1 -xvzf docker-17.03.1-ce.tgz -C /usr/local/bin

# Set exposed ports
EXPOSE 4545
ENV PORT=4545
ENV TEST_DB=db

# Cache elixir deps
COPY . .
ADD mix.exs mix.lock ./
ADD assets/package.json assets/

RUN mix do deps.get, deps.compile && \
  cd assets && \
  npm install && \
  npm run deploy && \
  cd - && \
  mix do deps.get, deps.compile, phx.digest
