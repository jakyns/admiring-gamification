use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ag, AG.Repo,
  username: "postgres",
  password: "postgres",
  database: "ag_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ag, AGWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :ag, slack_signing_secret: "965706f92502af345d1799d6b516c65b"

# Configures mock modules
config :ag, :user_storage, UserStorageMock
config :ag, :compliment_creator, ComplimentCreatorMock
config :ag, :slack_request_verifier, SlackRequestVerifierMock
