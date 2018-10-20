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

  @doc "Returns names matches by holder or owner of collaboration"
  @spec take_matched_names(integer()) :: {:ok, list(NameDescription.t())}
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
  @doc "Returns user specific favourtie names"
  @spec take_favourite_names(integer()) :: {:ok, list(NameDescription.t())}
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

  @doc "Returns uniq name set for user based on already viewed names"
  @type filter :: %{limit: non_neg_integer(), filter: %{gender: String.t()}}
  @spec take_unviewed_names(pos_integer(), filter()) :: {:ok, list(NameDescription.t())}
  def take_unviewed_names(user_id, params) do
    %{limit: limit, filter: filter} = params
    gender = String.downcase(filter.gender)

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

  @doc "Removes user's favourite name"
  @spec remove_favourite_name(pos_integer(), pos_integer()) :: {:ok, true} | {:error, :not_found}
  def remove_favourite_name(user_id, name_id) when is_nil(user_id) or is_nil(name_id),
    do: {:error, :not_found}

  def remove_favourite_name(user_id, name_id) do
    delete_query =
      from(ufn in UserFavouriteNames,
        where: ufn.user_id == ^user_id and ufn.name_id == ^name_id
      )

    case Repo.delete_all(delete_query) do
      {0, _} -> {:error, :not_found}
      {n, _} when n > 0 -> {:ok, true}
    end
  end

  @doc "Saves name as user's favourite"
  @spec marked_name_as_favourite(pos_integer(), pos_integer()) :: {:ok, true} | {:error, any()}
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
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  @doc "Marks name is already viewed by user"
  @spec marked_name_as_viewed(pos_integer(), pos_integer()) :: {:ok, true} | {:error, any()}
  def marked_name_as_viewed(user_id, name_id) do
    insertion_result =
      %UserViewedNames{}
      |> UserViewedNames.changeset(%{user_id: user_id, name_id: name_id})
      |> Repo.insert()

    case insertion_result do
      {:ok, _} -> {:ok, true}
      error -> error
    end
  end

  @doc "Resets unviewed names for particular user, except favourites"
  @spec reset_unviewed_names(pos_integer()) :: {:ok, true} | {:error, any()}
  def reset_unviewed_names(user_id) do
    viewed_names =
      from(uvn in UserViewedNames,
        left_join: ufn in UserFavouriteNames,
        on: uvn.name_id == ufn.name_id and uvn.user_id == ufn.user_id,
        where: uvn.user_id == ^user_id and is_nil(ufn.name_id),
        select: uvn.id
      )

    remove_ids = Repo.all(viewed_names)

    remove_query =
      from(uvn in UserViewedNames,
        where: uvn.id in ^remove_ids
      )

    case Repo.delete_all(remove_query) do
      {n, _} when is_number(n) -> {:ok, true}
      error -> {:error, error}
    end
  end
end
