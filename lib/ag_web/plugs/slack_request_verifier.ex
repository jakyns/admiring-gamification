defmodule AGWeb.SlackRequestVerifierBehaviour do
  @callback verify(binary(), binary(), binary()) :: boolean()
end

defmodule AGWeb.SlackRequestVerifier do
  @behaviour AGWeb.SlackRequestVerifierBehaviour

  @impl true
  def verify(timestamp, req_body, slack_signature) do
    sig_basestring = "v0:#{timestamp}:#{req_body}"

    "v0="
    |> Kernel.<>(:crypto.hmac(:sha256, slack_signing_secret(), sig_basestring) |> Base.encode16())
    |> String.downcase()
    |> Plug.Crypto.secure_compare(slack_signature)
  end

  defp slack_signing_secret do
    Application.get_env(:ag, :slack_signing_secret)
  end
end