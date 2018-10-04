defmodule BabyNames.Context.Accounts do
  @moduledoc """
  Accounts context
  """

  alias BabyNames.{Repo, Repo.User}

  def create_account(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_by_device_id(device_id) do
    case Repo.get_by(User, device_id: device_id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
