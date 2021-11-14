defmodule DmageWeb.MainLiveTest do
  use DmageWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, _disconnected_html} = live(conn, "/")
  end
end
