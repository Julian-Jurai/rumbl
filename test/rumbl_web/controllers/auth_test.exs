defmodule RumblWeb.AuthTest do 
  use RumblWeb.ConnCase, async: true
  alias RumblWeb.Auth

  test "authenticate_user halts when no current user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])
    assert conn.halted
  end
end