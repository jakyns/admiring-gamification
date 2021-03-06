defmodule AG.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    default_children = [
      # Start the Ecto repository
      AG.Repo,
      # Start the Telemetry supervisor
      AGWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: AG.PubSub},
      # Start the Endpoint (http/https)
      AGWeb.Endpoint
      # Start a worker by calling: AG.Worker.start_link(arg)
      # {AG.Worker, arg}
    ]

    children =
      if Application.get_env(:ag, :env) == :test do
        default_children
      else
        default_children ++
          [
            {AG.UserStorage, slack_api: AG.SlackAPI}
          ]
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AG.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AGWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
