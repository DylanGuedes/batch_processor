use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :batch_processor, BatchProcessorWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :batch_processor, BatchProcessor.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "batch_processor_test",
  hostname: System.get_env("TEST_DB"),
  pool: Ecto.Adapters.SQL.Sandbox

config :batch_processor, :environment, :test
