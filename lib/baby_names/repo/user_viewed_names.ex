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
    |> foreign_key_constraint(:user_id, message: "user doesn't exist")
    |> foreign_key_constraint(:name_id, message: "name description doesn't exist")
    |> validate_required([:user_id, :name_id])
  end
end
