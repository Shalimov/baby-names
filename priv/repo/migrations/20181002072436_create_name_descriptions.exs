defmodule BabyNames.Repo.Migrations.CreateNameDescriptions do
  use Ecto.Migration

  def change do
    create table(:name_descriptions) do
      add :name, :string, size: 40, null: false
      add :description, :text, null: false
      add :gender, :string, null: false
      add :name_dates, {:array, :string}
      add :origin, {:array, :string}
      add :short_forms, {:array, :string}

      timestamps()
    end
  end
end
