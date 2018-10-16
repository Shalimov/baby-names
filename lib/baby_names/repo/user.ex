defmodule BabyNames.Repo.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias BabyNames.Repo.{NameDescription}

  @type t :: %{
          id: integer(),
          device_id: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "users" do
    field(:device_id, :string)

    many_to_many(:favourite_names, NameDescription, join_through: "user_fav_names")
    many_to_many(:viewed_names, NameDescription, join_through: "user_viewed_names")

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:device_id])
    |> unique_constraint(:device_id, message: "User has already been registred")
    |> validate_required([:device_id])
  end
end
