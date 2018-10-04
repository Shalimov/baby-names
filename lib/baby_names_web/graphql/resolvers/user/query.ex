defmodule BabyNamesWeb.GraphQl.Resolvers.User.Query do
  @moduledoc """
  Simple query set for user data type
  """

  def me(_params, %{ context: context }) do
    {:ok, Map.get(context, :current_user)}
  end
end
