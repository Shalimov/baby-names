defmodule BabyNamesWeb.GraphQl.Resolvers.User.Mutation do
  @moduledoc """
  Mutation descriptions for user data type
  """

  alias BabyNames.Context.Accounts

  def create_user(params, _resolution) do
    Accounts.create_account(params)
  end
end
