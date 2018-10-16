defmodule BabyNames.Context.Accounts do
  @moduledoc """
  Accounts context helps user to create a new account or obtain existing by device id
  """

  alias BabyNames.{Repo, Repo.User}

  @doc "Creates new user if device_id is provided"
  @spec create_account(%{device_id: String.t()}) :: {:ok, User.t()} | {:error, any()}
  def create_account(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Returns user by device id"
  @spec get_by_device_id(String.t()) :: {:ok, User.t()} | {}
  def get_by_device_id(device_id) do
    case Repo.get_by(User, device_id: device_id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
