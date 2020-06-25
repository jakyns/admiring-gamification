defmodule AG.Repo.Migrations.CreateCompliments do
  use Ecto.Migration

  def change do
    create table(:compliments) do
      add :type, :string, null: false
      add :sender_id, :string, null: false
      add :recipient_id, :string, null: false
      add :description, :string
      add :created_date, :date, null: false

      timestamps(updated_at: false)
    end

    create unique_index(:compliments, [:sender_id, :created_date])
  end
end
