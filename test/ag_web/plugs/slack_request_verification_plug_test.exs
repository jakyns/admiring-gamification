defmodule AGWeb.SlackRequestVerificationPlugTest do
  use AGWeb.ConnCase, async: true

  alias AGWeb.SlackRequestVerificationPlug

  defmodule TestSlackRequestVerifier do
    @behaviour AGWeb.SlackRequestVerifierBehaviour

    @impl true
    def verify(_, _, slack_signature) do
      slack_signature == "v0=validsignature"
    end
  end

  describe "init/1" do
    test "returns the given verifier" do
      opts = [verifier: TestSlackRequestVerifier]

      result = SlackRequestVerificationPlug.init(opts)

      assert result == TestSlackRequestVerifier
    end

    test "returns default verifier if none is given" do
      opts = []

      result = SlackRequestVerificationPlug.init(opts)

      assert result == AGWeb.SlackRequestVerifier
    end
  end

  describe "call/2" do
    @verifier TestSlackRequestVerifier

    test "returns unauthorized if x-slack-request-timestamp is not provided", %{conn: conn} do
      conn = SlackRequestVerificationPlug.call(conn, @verifier)

      assert conn.status == 401
      assert conn.halted
    end

    test "returns unauthorized if the request timestamp is more than 5 minutes from the current timestamp", %{
      conn: conn
    } do
      timestamp =
        DateTime.utc_now()
        |> DateTime.to_unix(:second)
        |> Kernel.+(301)

      conn =
        conn
        |> put_req_header("x-slack-request-timestamp", to_string(timestamp))
        |> SlackRequestVerificationPlug.call(@verifier)

      assert conn.status == 401
      assert conn.halted
    end

    test "returns unauthorized if x-slack-signature is not provided", %{conn: conn} do
      timestamp =
        DateTime.utc_now()
        |> DateTime.to_unix(:second)
        |> Kernel.+(100)

      conn =
        conn
        |> put_req_header("x-slack-request-timestamp", to_string(timestamp))
        |> SlackRequestVerificationPlug.call(@verifier)

      assert conn.status == 401
      assert conn.halted
    end

    test "returns unauthorized if the given x-slack-signature is invalid", %{conn: conn} do
      timestamp =
        DateTime.utc_now()
        |> DateTime.to_unix(:second)
        |> Kernel.+(100)

      conn =
        conn
        |> put_req_header("x-slack-request-timestamp", to_string(timestamp))
        |> put_req_header("x-slack-signature", "v0=invalidsignature")
        |> SlackRequestVerificationPlug.call(@verifier)

      assert conn.status == 401
      assert conn.halted
    end

    test "does not halt the conn if the given x-slack-signature is valid", %{conn: conn} do
      timestamp =
        DateTime.utc_now()
        |> DateTime.to_unix(:second)
        |> Kernel.+(100)

      conn =
        conn
        |> put_req_header("x-slack-request-timestamp", to_string(timestamp))
        |> put_req_header("x-slack-signature", "v0=validsignature")
        |> SlackRequestVerificationPlug.call(@verifier)

      refute conn.halted
    end
  end
end
