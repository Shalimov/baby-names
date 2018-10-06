defmodule BabyNamesWeb.GraphQl.Resolvers.User.Mutation do
  @moduledoc """
  Mutation descriptions for user data type
  """

  alias BabyNames.Context.{Accounts, User}

  def create_user(params, _resolution) do
    Accounts.create_account(params)
  end

  def create_collaboration(params, %{ context: context }) do
    user = Map.get(context, :current_user)
    User.create_collaboration(user.id)
  end
end
