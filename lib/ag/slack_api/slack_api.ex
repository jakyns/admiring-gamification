defmodule AG.SlackAPI do
  alias AG.SlackAPI.User
  alias HTTPoison.Response

  @base_url "https://slack.com/api"
  @http_options [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: :timer.seconds(1)]

  @spec list_active_users(String.t()) :: {:ok, [User.t()]} | :error
  def list_active_users(base_url \\ @base_url) do
    url = base_url <> "/users.list"

    headers = [
      Authorization: "Bearer #{slack_token()}",
      Accept: "application/x-www-form-urlencoded"
    ]

    with {:ok, %Response{status_code: 200, body: body}} <- HTTPoison.get(url, headers, @http_options),
         %{"ok" => true, "members" => members} <- Jason.decode!(body) do
      {:ok, filter_and_map_to_users(members)}
    else
      _ -> :error
    end
  end

  defp filter_and_map_to_users(list) do
    Enum.flat_map(list, fn
      %{
        "name" => "slackbot"
      } ->
        []

      %{
        "deleted" => false,
        "is_bot" => false,
        "id" => id,
        "name" => name,
        "real_name" => real_name
      } ->
        [
          %User{
            id: id,
            name: name,
            real_name: real_name
          }
        ]

      _ ->
        []
    end)
  end

  defp slack_token do
    Application.get_env(:ag, :slack_token)
  end
end
