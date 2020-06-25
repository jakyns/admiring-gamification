defmodule AGWeb.SlackRequestVerificationPlugTest do
  use AGWeb.ConnCase, async: true

  import Mox

  alias AGWeb.SlackRequestVerificationPlug

  @verifier SlackRequestVerifierMock

  describe "init/1" do
    test "returns the given verifier" do
      opts = [verifier: @verifier]

      result = SlackRequestVerificationPlug.init(opts)

      assert result == @verifier
    end

    test "returns default verifier if none is given" do
      opts = []

      result = SlackRequestVerificationPlug.init(opts)

      assert result == AGWeb.SlackRequestVerifier
    end
  end

  describe "call/2" do
    setup :verify_on_exit!

    test "returns unauthorized if x-slack-request-timestamp is not provided", %{conn: conn} do
      @verifier
      |> expect(:verify, 0, fn _, _, _ -> true end)

      conn = SlackRequestVerificationPlug.call(conn, @verifier)

      assert conn.status == 401
      assert conn.halted
    end

    test "returns unauthorized if the request timestamp is more than 5 minutes from the current timestamp", %{
      conn: conn
    } do
      timestamp = create_timestamp(301)

      @verifier
      |> expect(:verify, 0, fn _, _, _ -> true end)

      conn =
        conn
        |> put_req_header("x-slack-request-timestamp", timestamp)
        |> SlackRequestVerificationPlug.call(@verifier)

      assert conn.status == 401
      assert conn.halted
    end

    test "returns unauthorized if x-slack-signature is not provided", %{conn: conn} do
      timestamp = create_timestamp(100)

      @verifier
      |> expect(:verify, 0, fn _, _, _ -> true end)

      conn =
        conn
        |> put_req_header("x-slack-request-timestamp", timestamp)
        |> SlackRequestVerificationPlug.call(@verifier)

      assert conn.status == 401
      assert conn.halted
    end

    test "returns unauthorized if the given x-slack-signature is invalid", %{conn: conn} do
      timestamp = create_timestamp(100)
      slack_signature = "v0=invalidsignature"

      @verifier
      |> expect(:verify, 1, fn ^timestamp, _, ^slack_signature -> false end)

      conn =
        conn
        |> put_req_header("x-slack-request-timestamp", timestamp)
        |> put_req_header("x-slack-signature", slack_signature)
        |> SlackRequestVerificationPlug.call(@verifier)

      assert conn.status == 401
      assert conn.halted
    end

    test "does not halt the conn if the given x-slack-signature is valid", %{conn: conn} do
      timestamp = create_timestamp(100)
      slack_signature = "v0=validsignature"

      @verifier
      |> expect(:verify, 1, fn ^timestamp, _, ^slack_signature -> true end)

      conn =
        conn
        |> put_req_header("x-slack-request-timestamp", timestamp)
        |> put_req_header("x-slack-signature", slack_signature)
        |> SlackRequestVerificationPlug.call(@verifier)

      refute conn.halted
    end

    defp create_timestamp(seconds_from_now) do
      DateTime.utc_now()
      |> DateTime.to_unix(:second)
      |> Kernel.+(seconds_from_now)
      |> to_string()
    end
  end
end
