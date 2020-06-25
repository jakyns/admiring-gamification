defmodule AG.UserStorageTest do
  use ExUnit.Case, async: true

  import Mox

  alias AG.SlackAPI.User
  alias AG.UserStorage

  setup :verify_on_exit!

  describe "get_user_by_name/1" do
    test "returns {:error, :not_found} if user cannot be found from the given name" do
      name = "tobio"

      SlackAPIMock
      |> expect(:list_active_users, 1, fn ->
        {:ok, []}
      end)

      pid = start_supervised!({UserStorage, [slack_api: SlackAPIMock]})
      allow(SlackAPIMock, self(), pid)
      :timer.sleep(100)

      result = UserStorage.get_user_by_name(name)

      assert result == {:error, :not_found}
    end

    test "returns {:error, :not_found} if users in the storage is not yet ready to be retrieved due to api error" do
      name = "bokuto"

      SlackAPIMock
      |> expect(:list_active_users, 1, fn -> :error end)

      pid = start_supervised!({UserStorage, [slack_api: SlackAPIMock]})
      allow(SlackAPIMock, self(), pid)
      :timer.sleep(100)

      result = UserStorage.get_user_by_name(name)

      assert result == {:error, :not_found}
    end

    test "returns {:ok, user} if user can be found from the given name" do
      name = "hinata"

      SlackAPIMock
      |> expect(:list_active_users, 1, fn ->
        {:ok, [%User{id: "U62921N0Z", name: "hinata", real_name: "Hinata Shoyo"}]}
      end)

      pid = start_supervised!({UserStorage, [slack_api: SlackAPIMock]})
      allow(SlackAPIMock, self(), pid)
      :timer.sleep(100)

      result = UserStorage.get_user_by_name(name)

      assert {:ok, %User{} = user} = result
      assert user.id == "U62921N0Z"
      assert user.name == "hinata"
      assert user.real_name == "Hinata Shoyo"
    end
  end
end
