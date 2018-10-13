defmodule BabyNamesWeb.GraphQl.Resolvers.User.Types do
  @moduledoc """
  User type set of spectific resolvers
  """

  alias BabyNames.Context.{User, Collaboration}

  def favourite_names(user, _params, _resolution) do
    User.take_favourite_names(user.id)
  end

  def matched_names(user, _params, _resolution) do
    User.take_matched_names(user.id)
  end

  def collaboration_token(user, _params, _resolution) do
    token = Collaboration.get_collaboration_token(user.id)
    {:ok, token}
  end

  def bound?(user, _params, _resolution) do
    bound? = Collaboration.user_connected?(user.id)
    {:ok, bound?}
  end
end
