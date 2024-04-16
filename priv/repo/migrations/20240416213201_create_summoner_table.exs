defmodule Example.Repo.Migrations.CreateSummonerTable do
  use Ecto.Migration

  def change do
    create table(:summoner) do
      add :riot_id, :string
      add :account_id, :string
      add :puuid, :string
      add :name, :string

      timestamps()
    end
  end
end
