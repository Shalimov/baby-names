defmodule BabyNames.Context.NameOperations do
  @moduledoc """
  Name operations provide tiny layer to fetch full name description by id
  """

  alias BabyNames.{Repo, Repo.NameDescription}

  @doc "Returns full name description by id"
  @spec get_name_description(pos_integer()) :: {:ok, String.t()} | {:error, any()}
  def get_name_description(id) do
    case Repo.get(NameDescription, id) do
      nil -> {:error, :not_found}
      name -> {:ok, name}
    end
  end
end
