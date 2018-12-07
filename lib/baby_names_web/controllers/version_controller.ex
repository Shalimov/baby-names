defmodule BabyNamesWeb.VersionController do
  use BabyNamesWeb, :controller

  def info(conn, _params) do
    {:ok, version} = :application.get_key(:baby_names, :vsn)

    send_resp(conn, 200, """
    APP: Baby Names
    VSN: #{version}
    """)
  end
end
