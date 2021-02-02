defmodule Rumbl.Repo.Migrations.AddSlugToVides do
  use Ecto.Migration

  def change do
    alter table(:videos) do 
      add :slug, :string
    end
  end
end
