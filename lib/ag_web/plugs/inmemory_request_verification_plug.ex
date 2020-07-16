defmodule AGWeb.InMemoryRequestVerificationPlug do
  @moduledoc """
  Verifying requests from Slack.

  https://api.slack.com/authentication/verifying-requests-from-slack
  """
  use AGWeb, :controller

  @impl Plug
  def call(conn, _) do
    conn
  end
end
