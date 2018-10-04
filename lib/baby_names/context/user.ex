defmodule BabyNames.Context.User do
  @moduledoc """
  User associated context includes operation
  """

  import Ecto.Query

  alias BabyNames.Repo
  alias BabyNames.Repo.{NameDescription, UserViewedNames, UserFavouriteNames}

  def take_favourite_names(user_id) do
    nd_query =
      from(nd in NameDescription,
        inner_join: uvn in UserFavouriteNames,
        on: nd.id == uvn.name_id,
        where: uvn.user_id == ^user_id,
        select: nd
      )

    {:ok, Repo.all(nd_query)}
  end

  def take_unviewed_names(user_id, params) do
    %{limit: limit, filter: filter} = params
    %{gender: gender} = filter

    unviewed_subquery = from(uvn in UserViewedNames, where: uvn.user_id == ^user_id)

    dynamic_query =
      if gender == "mixed",
        do: dynamic([nd, uvn], is_nil(uvn.name_id)),
        else: dynamic([nd, uvn], is_nil(uvn.name_id) and nd.gender == ^gender)

    unviewed_query =
      from(nd in NameDescription,
        left_join: uvn in subquery(unviewed_subquery),
        on: nd.id == uvn.name_id,
        where: ^dynamic_query,
        select: nd,
        limit: ^limit
      )

    {:ok, Repo.all(unviewed_query)}
  end

  def remove_collaboration() do
  end

  def create_collaboration() do
  end

  def remove_favourite_name() do
  end

  def marked_name_as_favourite() do
  end

  def marked_name_as_viewed() do
  end
end
