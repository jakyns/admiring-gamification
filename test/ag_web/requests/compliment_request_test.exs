defmodule AGWeb.ComplimentRequestTest do
  use AGWeb.ConnCase, async: true

  import Mox

  describe "POST /api/compliments" do
    @params %{"user_id" => "123", "command" => "/compliment", "text" => "@adele cool"}

    test "when request is not authorized", %{conn: conn} do
      SlackRequestVerifierMock
      |> expect(:verify, 1, fn _, _, _ -> false end)

      ComplimentCreatorMock
      |> expect(:create, 0, fn _, _, _ -> :ok end)

      conn = post(conn, Routes.compliment_path(conn, :create), @params)

      assert conn.status == 401
    end

    test "when request is authorized", %{conn: conn} do
      SlackRequestVerifierMock
      |> expect(:verify, 1, fn _, _, _ -> true end)

      ComplimentCreatorMock
      |> expect(:create, 1, fn _, _, _ -> :ok end)

      timestamp =
        DateTime.utc_now()
        |> DateTime.to_unix(:second)
        |> to_string()

      conn =
        conn
        |> put_req_header("x-slack-request-timestamp", timestamp)
        |> put_req_header("x-slack-signature", "v0=slacksignatur")
        |> post(Routes.compliment_path(conn, :create), @params)

      assert conn.status == 200
    end
  end
end
