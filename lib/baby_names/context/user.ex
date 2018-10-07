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

  def take_matched_names(_user_id) do
    {:ok, []}
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
    Repo.delete(fav_name)
  end

  def marked_name_as_favourite(user_id, name_id) do
    fav_name_changeset =
      UserFavouriteNames.changeset(%UserFavouriteNames{}, %{
        user_id: user_id,
        name_id: name_id
      })

    viewed_name_changeset =
      UserViewedNames.changeset(%UserFavouriteNames{}, %{
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

  def create_collaboration(owner_id) do
    collaboration = Repo.get_by(Collaboration, %{owner_id: owner_id})

    if collaboration do
      {:ok, collaboration.token}
    else
      collaboration =
        %Collaboration{}
        |> Collaboration.changeset(%{owner_id: owner_id})
        |> Repo.insert!(returning: [:token])

      {:ok, collaboration.token}
    end
  end

  def remove_collaboration(user_id, token) do
    collaboration = Repo.get_by!(Collaboration, %{token: token})

    if collaboration.owner_id == user_id or collaboration.holder_id == user_id do
      Repo.delete(collaboration)
    else
      {:error, :collaboration_removal_error}
    end
  end

  def is_user_connected(user_id) do
    query =
      from(c in Collaboration,
        where: c.holder_id == ^user_id or c.owner_id == ^user_id,
        select: c.id
      )

    case Repo.all(query) do
      [] -> true
      _ -> false
    end
  end

  def connect_collaboration(token, holder_id) do
    collaboration = Repo.get_by!(Collaboration, %{token: token})

    connection_result =
      cond do
        collaboration.holder_id ->
          {:error, :holder_already_exists}

        collaboration.owner_id == holder_id ->
          {:error, :holder_is_owner}

        is_user_connected(holder_id) ->
          {:error, :holder_bound}

        true ->
          collaboration
          |> Repo.User.connect_changset(%{holder_id: holder_id})
          |> Repo.update()
      end

    case connection_result do
      {:ok, _} -> {:ok, true}
      error -> error
    end
  end
end
