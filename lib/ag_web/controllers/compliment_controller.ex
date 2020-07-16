defmodule AGWeb.ComplimentController do
  use AGWeb, :controller

  alias AG.ComplimentCreator

  plug AGWeb.SlackRequestVerificationPlug, verifier: Application.get_env(:ag, :slack_request_verifier)

  @compliment_creator Application.get_env(:ag, :compliment_creator)

  def show(conn, %{"user_id" => recipient_id}) do
    conn
    |> put_status(:ok)
    |> json(%{"text" => "show compliment points of #{recipient_id}"})
  end

  def create(conn, %{"user_id" => sender_id, "command" => "/compliment", "text" => text}) do
    with {:ok, {recipient_name, type}} <- extract_recipient_name_and_type(text),
         :ok <- @compliment_creator.create(sender_id, recipient_name, type) do
      conn
      |> put_status(:ok)
      |> json(%{"text" => "Thanks for complimenting :)"})
    else
      {:error, %ComplimentCreator.Error{message: msg}} ->
        conn
        |> put_status(:ok)
        |> json(%{"text" => msg})

      {:error, msg} ->
        conn
        |> put_status(:ok)
        |> json(%{"text" => msg})
    end
  end

  def create(conn, _) do
    conn
    |> put_status(:bad_request)
    |> json(%{})
  end

  defp extract_recipient_name_and_type(text) do
    case String.split(text, " ", trim: true, parts: 3) do
      ["@" <> recipient_name, type] ->
        {:ok, {recipient_name, type}}

      ["@" <> recipient_name, type, _description] ->
        {:ok, {recipient_name, type}}

      _ ->
        {:error, "invalid format"}
    end
  end
end
