defmodule AGWeb.SlackRequestVerificationTest do
  use ExUnit.Case, async: true

  alias AGWeb.SlackRequestVerifier

  describe "verify/3" do
    test "returns false if the verification process is failed" do
      timestamp = "1592750937"
      req_body = [""]
      slack_signature = "v0=invalid"

      result = SlackRequestVerifier.verify(timestamp, req_body, slack_signature)

      assert result == false
    end

    test "returns true if the verification process is successful" do
      # NOTE: The following arguments are copied from the actual data when performing manual testing.

      timestamp = "1592750937"

      req_body = [
        "token=fRCFtG5wSQrsgpCuiLKUMGMp&team_id=T625Q5Q3A&team_domain=urthe&channel_id=D63KZQ030&channel_name=directmessage&user_id=U62921N0Z&user_name=ash&command=%2Fadmire&text=%40kyloren+hello+world&response_url=https%3A%2F%2Fhooks.slack.com%2Fcommands%2FT625Q5Q3A%2F1196950375075%2Fr2nEFHbPBCYW1yC7E7tQHIuJ&trigger_id=1181999365895.206194194112.3caa7906fc488b9550983da3bb864012"
      ]

      slack_signature = "v0=9be27a6b624392d61662574811aab611963583810db856ae3b6aeae8e167d9b4"

      result = SlackRequestVerifier.verify(timestamp, req_body, slack_signature)

      assert result == true
    end
  end
end
