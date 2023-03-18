defmodule Vejper.Repo.Migrations.PopulateCategoriesAndFields do
  use Ecto.Migration
  import Ecto.Query
  alias Vejper.Repo
  alias Vejper.Store.{Field, Category}

  def up do
    [q, w, e, r, t, y] = [
      %{"name" => "Broj grejača", "type" => "select", "values" => ["1", "2", "3", "4", "5"]},
      %{
        "name" => "Tip",
        "type" => "select",
        "values" => ["Fabrički grejači", "RTA", "RDA", "RDTA"]
      },
      %{"name" => "Kapacitet tanka", "type" => "number", "values" => []},
      %{"name" => "Čip", "type" => "select", "values" => ["DNA", "Mehanika", "Fabrički"]},
      %{
        "name" => "Baterija",
        "type" => "select",
        "values" => ["Ugrađena", "Jedna", "Dve", "Tri", "Četiri", "Više od četiri"]
      },
      %{"name" => "Skvonk", "type" => "select", "values" => ["Da", "Ne"]}
    ]

    #   categories = ["Atomizer", "Mod", "Ostalo"]

    # Enum.map(fields, fn field -> Field.changeset(%Field{}, field) |>Repo.insert!)
    %Category{}
    |> Category.changeset(%{"name" => "Atomizer", "fields" => [q, w, e]})
    |> Ecto.Changeset.cast_assoc(:fields)
    |> Repo.insert!()

    %Category{}
    |> Category.changeset(%{"name" => "Mod", "fields" => [r, t, y]})
    |> Ecto.Changeset.cast_assoc(:fields)
    |> Repo.insert!()

    %Category{}
    |> Category.changeset(%{"name" => "Ostalo"})
    |> Repo.insert!()
  end

  def down do
    Repo.delete_all(Category)
    Repo.delete_all(Field)
    Repo.delete_all(from(p in "store_categories_fields"))
  end
end
