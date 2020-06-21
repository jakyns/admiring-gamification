defmodule AGWeb.CacheBodyReaderTest do
  use AGWeb.ConnCase, async: true

  alias AGWeb.CacheBodyReader

  describe "read_body/2" do
    test "reads the body and assigns it to raw_body key of the given conn", %{conn: conn} do
      opts = []

      result = CacheBodyReader.read_body(conn, opts)

      assert {:ok, body, conn} = result
      assert body == ""
      assert conn.assigns[:raw_body] == [body]
    end
  end
end
