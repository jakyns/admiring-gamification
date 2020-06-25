defmodule AG.UserStorageBehaviour do
  @callback get_user_by_name(String.t()) :: {:ok, AG.SlackAPI.User.t()} | {:error, :not_found}
end
