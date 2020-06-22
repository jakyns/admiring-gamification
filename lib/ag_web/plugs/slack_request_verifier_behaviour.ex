defmodule AGWeb.SlackRequestVerifierBehaviour do
  @callback verify(binary(), binary(), binary()) :: boolean()
end
