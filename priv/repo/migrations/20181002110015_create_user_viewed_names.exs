defmodule BabyNames.Repo.Migrations.CreateUserViewedNames do
  use Ecto.Migration

  def change do
    create table(:user_viewed_names) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :name_id, references(:name_descriptions, on_delete: :delete_all)

      timestamps()
    end

    create index(:user_viewed_names, [:user_id])
    create index(:user_viewed_names, [:name_id])
  end
end
