defmodule AGWeb.ComplimentControllerTest do
  use AGWeb.ConnCase

  import Mox

  alias AG.ComplimentCreator.Error
  alias AGWeb.ComplimentController

  setup :verify_on_exit!

  describe "create/2" do
    test "with invalid params", %{conn: conn} do
      params = %{}

      ComplimentCreatorMock
      |> expect(:create, 0, fn _, _, _ -> :ok end)

      conn = ComplimentController.create(conn, params)

      assert json_response(conn, 400)
    end

    test "with invalid text format", %{conn: conn} do
      params = %{"user_id" => "123", "command" => "/compliment", "text" => "this is an invalid text"}

      ComplimentCreatorMock
      |> expect(:create, 0, fn _, _, _ -> :ok end)

      conn = ComplimentController.create(conn, params)

      assert json_response(conn, 200) == %{
               "text" => "invalid format"
             }
    end

    test "when compliment cannot be created", %{conn: conn} do
      sender_id = "123"
      recipient_name = "hinata"
      type = "awesome"
      params = %{"user_id" => sender_id, "command" => "/compliment", "text" => "@#{recipient_name} #{type}"}

      ComplimentCreatorMock
      |> expect(:create, 1, fn ^sender_id, ^recipient_name, ^type -> {:error, %Error{message: "boom"}} end)

      conn = ComplimentController.create(conn, params)

      assert json_response(conn, 200) == %{"text" => "boom"}
    end

    test "when compliment can be created", %{conn: conn} do
      sender_id = "123"
      recipient_name = "hinata"
      type = "awesome"
      params = %{"user_id" => sender_id, "command" => "/compliment", "text" => "@#{recipient_name} #{type}"}

      ComplimentCreatorMock
      |> expect(:create, 1, fn ^sender_id, ^recipient_name, ^type -> :ok end)

      conn = ComplimentController.create(conn, params)

      assert json_response(conn, 200) == %{"text" => "Thanks for complimenting :)"}
    end
  end
end
