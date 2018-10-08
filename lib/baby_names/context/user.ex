defmodule BabyNames.Context.User do
  @moduledoc """
  User associated context includes operation
  """

  import Ecto.Query
  alias Ecto.Multi

  alias BabyNames.Repo

  alias BabyNames.Repo.{
    Collaboration,
    NameDescription,
    UserViewedNames,
    UserFavouriteNames
  }

  def take_matched_names(user_id) do
    match_query =
      from(
        c in Collaboration,
        join: ouvn in UserFavouriteNames,
        on: c.owner_id == ouvn.user_id,
        join: hovn in UserFavouriteNames,
        on: c.holder_id == hovn.user_id,
        join: nd in NameDescription,
        on: nd.id == ouvn.name_id and ouvn.name_id == hovn.name_id,
        where: c.owner_id == ^user_id or c.holder_id == ^user_id,
        select: nd
      )

    {:ok, Repo.all(match_query)}
  end

  # mb use assoc instead of join
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
      if gender == "MIXED",
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

  # Could be improved by using Repo.delete_all/2
  def remove_favourite_name(user_id, name_id) do
    fav_name = Repo.get_by!(UserFavouriteNames, %{user_id: user_id, name_id: name_id})

    case Repo.delete(fav_name) do
      {:ok, _} -> {:ok, true}
      error -> error
    end
  end

  def marked_name_as_favourite(user_id, name_id) do
    fav_name_changeset =
      UserFavouriteNames.changeset(%UserFavouriteNames{}, %{
        user_id: user_id,
        name_id: name_id
      })

    viewed_name_changeset =
      UserViewedNames.changeset(%UserViewedNames{}, %{
        user_id: user_id,
        name_id: name_id
      })

    result =
      Multi.new()
      |> Multi.insert(:fav_name, fav_name_changeset)
      |> Multi.insert(:viewed_name, viewed_name_changeset)
      |> Repo.transaction()

    case result do
      {:ok, _changes} -> {:ok, true}
      error -> error
    end
  end

  def marked_name_as_viewed(user_id, name_id) do
    %UserViewedNames{}
    |> UserViewedNames.changeset(%{user_id: user_id, name_id: name_id})
    |> Repo.insert!()

    {:ok, true}
  end
end
