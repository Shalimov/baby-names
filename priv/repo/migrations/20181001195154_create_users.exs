defmodule BabyNames.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :device_id, :string

      timestamps()
    end

    create unique_index(:users, [:device_id])
  end
end
