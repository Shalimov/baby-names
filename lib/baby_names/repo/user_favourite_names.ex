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
    |> cast(attrs, [])
    |> validate_required([])
  end
end
