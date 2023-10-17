defmodule ConnectService.Repo.Migrations.CreateTransfer do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:transfers) do
      add :uuid, :uuid, null: false

      add :amount, :float
      add :status, :string
      add :expires_at, :utc_datetime

      timestamps()
    end
  end
end
