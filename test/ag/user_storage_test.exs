defmodule AG.UserStorageTest do
  use ExUnit.Case

  alias AG.SlackAPI.User
  alias AG.UserStorage

  defmodule TestSlackAPI do
    def list_active_users do
      {:ok, [%User{id: "U62921N0Z", name: "hinata", real_name: "Hinata Shoyo"}]}
    end
  end

  setup_all do
    opts = [slack_api: TestSlackAPI]
    start_supervised!({UserStorage, opts})
    :timer.sleep(100)

    :ok
  end

  describe "get_user_by_name/1" do
    test "returns {:error, :not_found} if user cannot be found from the given name" do
      name = "tobio"

      result = UserStorage.get_user_by_name(name)

      assert result == {:error, :not_found}
    end

    test "returns {:ok, user} if user can be found from the given name" do
      name = "hinata"

      result = UserStorage.get_user_by_name(name)

      assert {:ok, %User{} = user} = result
      assert user.id == "U62921N0Z"
      assert user.name == "hinata"
      assert user.real_name == "Hinata Shoyo"
    end
  end
end
