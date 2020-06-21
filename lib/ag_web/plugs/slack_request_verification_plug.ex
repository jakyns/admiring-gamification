defmodule AGWeb.SlackRequestVerificationPlug do
  @moduledoc """
  Verifying requests from Slack.

  https://api.slack.com/authentication/verifying-requests-from-slack
  """
  use AGWeb, :controller

  @five_minutes_in_second 5 * 60

  @impl Plug
  def init(opts) do
    Keyword.get(opts, :verifier, AGWeb.SlackRequestVerifier)
  end

  @impl Plug
  def call(conn, verifier) do
    with [timestamp] <- get_req_header(conn, "x-slack-request-timestamp"),
         true <- check_timestamp(timestamp),
         [slack_signature] <- get_req_header(conn, "x-slack-signature"),
         true <- verifier.verify(timestamp, conn.assigns[:raw_body], slack_signature) do
      conn
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{})
        |> halt()
    end
  end

  defp check_timestamp(timestamp) do
    current_unix_time = DateTime.to_unix(DateTime.utc_now(), :second)
    abs(current_unix_time - String.to_integer(timestamp)) <= @five_minutes_in_second
  end
end
