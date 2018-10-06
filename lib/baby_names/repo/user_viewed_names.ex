defmodule BabyNames.Repo.UserViewedNames do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_viewed_names" do
    field(:user_id, :id)
    field(:name_id, :id)

    timestamps()
  end

  @doc false
  def changeset(user_viewed_names, attrs) do
    user_viewed_names
    |> cast(attrs, [:user_id, :name_id])
    |> validate_required([:user_id, :name_id])
  end
end
