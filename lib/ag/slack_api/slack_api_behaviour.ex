defmodule AG.SlackAPIBehaviour do
  @callback list_active_users :: {:ok, [User.t()]} | :error
end
