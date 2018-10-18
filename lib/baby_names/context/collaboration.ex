defmodule BabyNames.Context.Collaboration do
  @moduledoc """
  Collaboration module helps to create connection between two users
  and provide indirect ability to share matched names
  """

  import Ecto.Query

  alias BabyNames.Repo
  alias BabyNames.Repo.Collaboration

  def create_collaboration(nil), do: {:error, :owner_not_found}

  @doc "Creates collaboration record for owner with generated V4 token"
  @spec create_collaboration(pos_integer()) :: {:ok, String.t()} | {:error, any()}
  def create_collaboration(owner_id) do
    token = get_collaboration_token(owner_id)

    if token do
      {:ok, token}
    else
      collaboration_result =
        %Collaboration{}
        |> Collaboration.changeset(%{owner_id: owner_id})
        |> Repo.insert(returning: [:token])

      case collaboration_result do
        {:ok, %{token: token}} -> {:ok, token}
        error -> error
      end
    end
  end

  @doc "Removes collaboration completely for user if user is owner or holder"
  @spec remove_collaboration(pos_integer(), String.t()) :: {:ok, any()} | {:error, any()}
  def remove_collaboration(user_id, token) do
    collaboration = token && Repo.get_by(Collaboration, token: token)

    has_collaboration? =
      collaboration != nil and user_id != nil and
        (collaboration.owner_id == user_id or collaboration.holder_id == user_id)

    if has_collaboration? do
      Repo.delete(collaboration)
    else
      {:error, :collaboration_removal_error}
    end
  end

  def get_collaboration_token(nil), do: nil

  @doc "Returns collaboration token if user is owner or holder of collaboration"
  @spec get_collaboration_token(pos_integer()) :: String.t() | nil
  def get_collaboration_token(user_id) do
    query =
      from(c in Collaboration,
        where: c.holder_id == ^user_id or c.owner_id == ^user_id,
        select: c.token
      )

    Repo.one(query)
  end

  def user_connected?(nil), do: false

  @doc "Returns information whether user is connected to other user via collaboration"
  @spec user_connected?(pos_integer()) :: boolean()
  def user_connected?(user_id) do
    query =
      from(c in Collaboration,
        where: (c.holder_id == ^user_id or c.owner_id == ^user_id) and not is_nil(c.holder_id),
        select: c.id,
        limit: 1
      )

    Repo.one(query) != nil
  end

  # In some cases holder can owe a collaboration already
  # in this case this collaboration should be removed
  @doc "Connects holder with owner in boundaries of collaboration"
  @spec connect_collaboration(String.t(), pos_integer()) :: {:ok, true} | {:error, any()}
  def connect_collaboration(token, holder_id) do
    collaboration = token && Repo.get_by(Collaboration, token: token)

    connection_result =
      cond do
        is_nil(collaboration) ->
          {:error, :not_found}

        collaboration.holder_id ->
          {:error, :holder_exists}

        collaboration.owner_id == holder_id ->
          {:error, :holder_is_owner}

        connected_as_holder?(holder_id) ->
          {:error, :holder_bound}

        true ->
          collaboration
          |> Repo.Collaboration.connect_changeset(%{holder_id: holder_id})
          |> Repo.update()
      end

    case connection_result do
      {:ok, _} -> {:ok, true}
      error -> error
    end
  end

  defp connected_as_holder?(nil), do: false

  @spec connected_as_holder?(pos_integer()) :: boolean()
  defp connected_as_holder?(holder_id) do
    query =
      from(c in Collaboration,
        where: c.holder_id == ^holder_id,
        select: c.id,
        limit: 1
      )

    Repo.one(query) != nil
  end
end
