defmodule BabyNames.Repo.Migrations.CreateUserFavNames do
  use Ecto.Migration

  def change do
    create table(:user_fav_names) do
      add(:user_id, references(:users, on_delete: :delete_all))
      add(:name_id, references(:name_descriptions, on_delete: :delete_all))

      timestamps()
    end

    create(index(:user_fav_names, [:user_id]))
    create(index(:user_fav_names, [:name_id]))

    create(unique_index(:user_fav_names, [:user_id, :name_id], name: :user_fav_uniq_bound))
  end
end
