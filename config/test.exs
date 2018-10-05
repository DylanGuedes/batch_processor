use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :data_processor, DataProcessorWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :data_processor, DataProcessor.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "data_processor_test",
  hostname: System.get_env("TEST_DB"),
  port: System.get_env("DB_PORT"),
  pool: Ecto.Adapters.SQL.Sandbox

config :data_processor, :environment, :test
