defmodule BabyNamesWeb.GraphQl.Resolvers.User.Types do
  @moduledoc """
  User type set of spectific resolvers
  """

  alias BabyNames.Context.User

  def favourite_names(user, _params, _resolution) do
    User.take_favourite_names(user.id)
  end

  def matched_names(user, _params, _resolution) do
    User.take_matched_names(user.id)
  end
end
