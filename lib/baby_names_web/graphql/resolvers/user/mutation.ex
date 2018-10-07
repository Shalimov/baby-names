defmodule BabyNamesWeb.GraphQl.Resolvers.User.Mutation do
  @moduledoc """
  Mutation descriptions for user data type
  """

  alias BabyNames.Context.{Accounts, User}

  def create_user(params, _resolution) do
    Accounts.create_account(params)
  end

  def create_collaboration(params, %{context: context}) do
    user = Map.get(context, :current_user)
    User.create_collaboration(user.id)
  end

  def connect(%{token: token}, %{context: context}) do
    user = Map.get(context, :current_user)
    User.connect_collaboration(token, user.id)
  end

  def disconnect(%{token: token}, %{context: context}) do
    user = Map.get(context, :current_user)
    User.remove_collaboration(token, user.id)
  end

  def mark_name_as_viewed(%{id: name_id}, %{context: context}) do
    user = Map.get(context, :current_user)
    User.marked_name_as_viewed(user.id, name_id)
  end

  def remember_name(%{id: name_id}, %{context: context}) do
    user = Map.get(context, :current_user)
    User.marked_name_as_favourite(user.id, name_id)
  end

  def forget_name(%{id: name_id}, %{context: context}) do
    user = Map.get(context, :current_user)
    User.remove_favourite_name(user.id, name_id)
  end
end
