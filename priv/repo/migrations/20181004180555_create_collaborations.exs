defmodule BabyNames.Repo.Migrations.CreateCollaborations do
  use Ecto.Migration

  def change do
    create table(:collaborations) do
      add(:token, :uuid, default: fragment("uuid_generate_v4()"))
      add(:owner_id, references(:users, on_delete: :nothing))
      add(:holder_id, references(:users, on_delete: :nothing))

      timestamps()
    end

    create(unique_index(:collaborations, [:token]))
    create(index(:collaborations, [:owner_id]))
    create(index(:collaborations, [:holder_id]))
  end
end
