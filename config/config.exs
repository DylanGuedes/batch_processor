# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :data_processor,
  ecto_repos: [DataProcessor.Repo]

# Configures the endpoint
config :data_processor, DataProcessorWeb.Endpoint,
  url: [host: System.get_env("DB_HOST"), port: System.get_env("DB_PORT")],
  secret_key_base: "gXobmTsMbqjk69LoJhWkJMENIMgXG0eTgi9a8wem58yyluFRoMiRJGrzvs04L5OB",
  render_errors: [view: DataProcessorWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DataProcessor.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :data_processor, :environment, Mix.env()

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: DataProcessor.Coherence.User,
  repo: DataProcessor.Repo,
  module: DataProcessor,
  web_module: DataProcessorWeb,
  router: DataProcessorWeb.Router,
  messages_backend: DataProcessorWeb.Coherence.Messages,
  logged_out_url: "/",
  registration_permitted_attributes: ["email","name","password","current_password","password_confirmation"],
  invitation_permitted_attributes: ["name","email"],
  password_reset_permitted_attributes: ["reset_password_token","password","password_confirmation"],
  session_permitted_attributes: ["remember","email","password"],
  opts: [:authenticatable]
# %% End Coherence Configuration %%
