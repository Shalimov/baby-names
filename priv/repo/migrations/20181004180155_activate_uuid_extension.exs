defmodule BabyNames.Repo.Migrations.ActivateUuidExtension do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";")
  end
end
