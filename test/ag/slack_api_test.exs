defmodule AG.SlackAPITest do
  use ExUnit.Case, async: true

  alias AG.SlackAPI
  alias AG.SlackAPI.User

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "list_users/1" do
    test "returns :error when users cannot be listed", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, ~s(
          {"ok": false}
        ))
      end)

      result = SlackAPI.list_users("http://localhost:#{bypass.port}")

      assert result == :error
    end

    test "returns {:ok, users} when users can be listed successfully", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, ~s(
          {
            "ok": true,
            "members": [
              {"deleted": false, "is_bot": false, "id": "U62921N0Z", "name": "hinata", "real_name": "Hinata Shoyo"},
              {"deleted": true, "is_bot": false, "id": "U625Q5Q6L", "name": "kyloren", "real_name": "Ben Solo"},
              {"deleted": false, "is_bot": true, "id": "U01032QJXNH", "name": "googledrive", "real_name": "Google Drive"},
              {"deleted": false, "is_bot": false, "id": "USLACKBOT", "name": "slackbot", "real_name": "Slack Bot"}
            ]
          }
        ))
      end)

      result = SlackAPI.list_users("http://localhost:#{bypass.port}")

      assert result ==
               {:ok,
                [
                  %User{id: "U62921N0Z", name: "hinata", real_name: "Hinata Shoyo"}
                ]}
    end
  end
end
