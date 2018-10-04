defmodule BabyNames.Context.NameOperations do
  @moduledoc """
  Simple context to administer name queries and update/insert operations
  """

  alias BabyNames.{Repo, Repo.NameDescription}

  def get_name_description(id) do
    case Repo.get(NameDescription, id) do
      nil -> {:error, :not_found}
      name -> {:ok, name}
    end
  end
end
