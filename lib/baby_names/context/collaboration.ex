defmodule BabyNames.Context.Collaboration do
  import Ecto.Query

  alias BabyNames.Repo
  alias BabyNames.Repo.Collaboration

  def create_collaboration(owner_id) do
    token = get_collaboration_token(owner_id)

    if token do
      {:ok, token}
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

  def get_collaboration_token(user_id) do
    query =
      from(c in Collaboration,
        where: c.holder_id == ^user_id or c.owner_id == ^user_id,
        select: c.token
      )

    Repo.one(query)
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
          |> Repo.Collaboration.connect_changeset(%{holder_id: holder_id})
          |> Repo.update()
      end

    case connection_result do
      {:ok, _} -> {:ok, true}
      error -> error
    end
  end
end
