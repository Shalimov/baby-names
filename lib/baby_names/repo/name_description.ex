defmodule BabyNames.Repo.NameDescription do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %{
          id: integer(),
          name: String.t(),
          gender: String.t(),
          description: String.t(),
          origin: list(String.t()),
          name_dates: list(String.t()),
          short_forms: list(String.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "name_descriptions" do
    field(:name, :string)
    field(:gender, :string)
    field(:description, :string)
    field(:origin, {:array, :string})
    field(:name_dates, {:array, :string})
    field(:short_forms, {:array, :string})

    timestamps()
  end

  @doc """
  Simple changeset to support insertion
  """
  def changeset(name_description, attrs) do
    name_description
    |> cast(attrs, [:name, :description, :gender, :name_dates, :origin, :short_forms])
    |> validate_sub_length(:name_dates, 10)
    |> validate_sub_length(:short_forms, 40)
    |> validate_sub_length(:origin, 30)
    |> validate_inclusion(:gender, ~w(female male))
    |> validate_required([:name, :description, :gender])
  end

  defp validate_sub_length(changeset, field, maxlen, options \\ []) do
    validate_change(changeset, field, fn _, values ->
      if Enum.all?(values, fn nd -> String.length(nd) <= maxlen end),
        do: [],
        else: [{field, options[:message] || "#{field} length should be less or equall #{maxlen}"}]
    end)
  end
end
