defmodule Vejper.Repo.Migrations.CreateMetaLists do
  alias Vejper.Meta.Lists
  use Ecto.Migration

  def change do
    create table(:meta_lists, primary_key: false) do
      add :name, :string, primary_key: true
      add :items, {:array, :string}

      timestamps()
    end

    create unique_index(:meta_lists, [:name])

    cities = [
      "Beograd",
      "Bor",
      "Valjevo",
      "Vranje",
      "Vršac",
      "Zaječar",
      "Zrenjanin",
      "Jagodina",
      "Kikinda",
      "Kragujevac",
      "Kraljevo",
      "Kruševac",
      "Leskovac",
      "Loznica",
      "Niš",
      "Novi Pazar",
      "Novi Sad",
      "Pančevo",
      "Pirot",
      "Požarevac",
      "Priština",
      "Prokuplje",
      "Smederevo",
      "Sombor",
      "Sremska Mitrovica",
      "Subotica",
      "Užice",
      "Čačak",
      "Šabac"
    ]

    states = [
      "Novo",
      "Samo probano",
      "Korišćeno",
      "Vidljivi tragovi korišćenja",
      "Oštećeno",
      "Neupotrebljivo"
    ]

    flush()
    Vejper.Repo.insert(Lists.changeset(%Lists{}, %{"name" => "cities", "items" => cities}))
    Vejper.Repo.insert(Lists.changeset(%Lists{}, %{"name" => "ad_states", "items" => states}))
  end
end
