defmodule BabyNames.Repo.UserFavouriteNames do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_fav_names" do
    field(:user_id, :id)
    field(:name_id, :id)

    timestamps()
  end

  @doc false
  def changeset(user_favourite_names, attrs) do
    user_favourite_names
    |> cast(attrs, [:user_id, :name_id])
    |> foreign_key_constraint(:user_id, message: "user doesn't exist")
    |> foreign_key_constraint(:name_id, message: "name description doesn't exist")
    |> unique_constraint(:user_name_constraint, name: :user_fav_uniq_bound)
    |> validate_required([:user_id, :name_id])
  end
end
