# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :ag,
  namespace: AG,
  ecto_repos: [AG.Repo],
  slack_token: System.get_env("SLACK_TOKEN")

# Configures the endpoint
config :ag, AGWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9l4DQXSRQ1t+8kGpzGdkMfDlqO7ssBHTUpV/uEaIt1a8DyTpz4oXVgexyxJvDqrE",
  render_errors: [view: AGWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: AG.PubSub,
  live_view: [signing_salt: "EuZrcPF4"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
