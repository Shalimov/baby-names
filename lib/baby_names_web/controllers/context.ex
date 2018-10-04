defmodule BabyNamesWeb.Context do
  @behaviour Plug

  import Plug.Conn

  alias BabyNames.Context.Accounts

  def init(opts), do: opts

  def get_device_key(_conn) do
    # get_req_header(conn, "x-device-key")
    ["sweet-heli"] # used fir test
  end

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  @doc """
  Return the current user context based on the device-id
  """
  def build_context(conn) do
    with [device_id] <- get_device_key(conn),
         {:ok, current_user} <- Accounts.get_by_device_id(device_id) do
      %{current_user: current_user}
    else
      _ -> %{}
    end
  end
end
