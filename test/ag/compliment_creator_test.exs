defmodule AG.ComplimentCreatorTest do
  use AG.DataCase

  import Mox

  alias AG.{Compliment, ComplimentCreator}
  alias AG.ComplimentCreator.Error
  alias AG.SlackAPI.User

  setup :verify_on_exit!

  describe "create/3" do
    test "returns error when user cannot be found from the given recipient_name" do
      sender_id = "abc"
      recipient_name = "adele"
      type = "helpful"

      UserStorageMock
      |> expect(:get_user_by_name, fn ^recipient_name -> {:error, :not_found} end)

      result = ComplimentCreator.create(sender_id, recipient_name, type)

      assert {:error, %Error{message: msg}} = result
      assert msg == "user adele not found"
    end

    test "returns error when sender and recipient are the same" do
      sender_id = "abc"
      recipient_name = "adele"
      type = "helpful"

      UserStorageMock
      |> expect(:get_user_by_name, fn ^recipient_name -> {:ok, %User{id: sender_id}} end)

      result = ComplimentCreator.create(sender_id, recipient_name, type)

      assert {:error, %Error{message: msg}} = result
      assert msg == "recipient and sender cannot be the same"
    end

    test "returns error when the given type is invalid" do
      sender_id = "abc"
      recipient_id = "def"
      recipient_name = "adele"
      type = "useless"

      UserStorageMock
      |> expect(:get_user_by_name, fn ^recipient_name -> {:ok, %User{id: recipient_id}} end)

      result = ComplimentCreator.create(sender_id, recipient_name, type)

      assert {:error, %Error{message: msg}} = result
      assert msg == "type is invalid"
    end

    test "returns ok when compliment can be created" do
      sender_id = "abc"
      recipient_id = "def"
      recipient_name = "adele"
      type = "helpful"

      UserStorageMock
      |> expect(:get_user_by_name, fn ^recipient_name -> {:ok, %User{id: recipient_id}} end)

      result = ComplimentCreator.create(sender_id, recipient_name, type)

      assert result == :ok
      assert %Compliment{sender_id: ^sender_id, recipient_id: ^recipient_id, type: ^type} = Repo.one(Compliment)
    end

    test "returns error when compliment is created more than once in 1 day" do
      sender_id = "abc"
      recipient_id = "def"
      recipient_name = "adele"
      type = "helpful"

      UserStorageMock
      |> expect(:get_user_by_name, 2, fn ^recipient_name -> {:ok, %User{id: recipient_id}} end)

      :ok = ComplimentCreator.create(sender_id, recipient_name, type)
      result = ComplimentCreator.create(sender_id, recipient_name, type)

      assert {:error, %Error{message: msg}} = result
      assert msg == "compliment can be created once per day"
    end
  end
end
