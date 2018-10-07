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

  def collaboration_token(user, _params, _resolution) do
    collaboration = User.get_collaboration(user.id)

    if collaboration do
      {:ok, collaboration.token}
    else
      {:ok, nil}
    end
  end

  def bound?(user, _params, _resolution) do
    bound? = User.is_user_connected(user.id)
    {:ok, bound?}
  end
end
