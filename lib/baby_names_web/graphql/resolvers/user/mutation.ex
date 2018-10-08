defmodule BabyNamesWeb.GraphQl.Resolvers.User.Mutation do
  @moduledoc """
  Mutation descriptions for user data type
  """

  alias BabyNames.Context.{Accounts, User, Collaboration}

  def resolve_by(fun_name) do
    fn params, resolution ->
      user = Map.get(resolution.context, :current_user)
      apply(__MODULE__, fun_name, [params, resolution, user])
    end
  end

  def create_user(params, _resolution) do
    Accounts.create_account(params)
  end

  def create_collaboration(_params, _, user) do
    Collaboration.create_collaboration(user.id)
  end

  def connect(%{token: token}, _, user) do
    Collaboration.connect_collaboration(token, user.id)
  end

  def disconnect(%{token: token}, _, user) do
    Collaboration.remove_collaboration(token, user.id)
  end

  def mark_name_as_viewed(%{id: name_id}, _, user) do
    User.marked_name_as_viewed(user.id, name_id)
  end

  def remember_name(%{id: name_id}, _, user) do
    User.marked_name_as_favourite(user.id, name_id)
  end

  def forget_name(%{id: name_id}, _, user) do
    User.remove_favourite_name(user.id, name_id)
  end
end
