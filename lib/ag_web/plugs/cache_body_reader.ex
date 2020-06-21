defmodule AGWeb.CacheBodyReader do
  alias Plug.Conn

  @doc """
  Reads the request body and stores it in the connection.

  https://hexdocs.pm/plug/Plug.Parsers.html#module-custom-body-reader
  """
  @spec read_body(Conn.t(), Keyword.t()) :: {:ok, binary, Conn.t()}
  def read_body(conn, opts) do
    {:ok, body, conn} = Conn.read_body(conn, opts)
    conn = update_in(conn.assigns[:raw_body], &[body | &1 || []])
    {:ok, body, conn}
  end
end
