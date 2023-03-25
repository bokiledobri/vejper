defmodule Vejper.Store.Ad.Field do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name
    field :value
    field :type
    field :values, {:array, :string}
  end

  def changeset(field, attrs \\ %{}) do
    field
    |> cast(attrs, [:name, :value, :type, :values])
    |> validate_required([:name])
  end
end

defmodule Vejper.Store.Ad do
  use Ecto.Schema
  import Ecto.Changeset
  alias Vejper.Store.Ad.Field

  schema "store_ads" do
    field :city, :string
    field :description, :string
    embeds_many :fields, Field, on_replace: :delete
    field :price, :integer
    field :state, :string
    field :title, :string
    belongs_to :user, Vejper.Accounts.User, on_replace: :nilify
    belongs_to :category, Vejper.Store.Category, on_replace: :nilify
    many_to_many :images, Vejper.Media.Image, join_through: "ads_images", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(ad, attrs, %Vejper.Store.Category{} = category, images) do
    IO.inspect(%{"attrs[fields]" => attrs["fields"]})
    IO.inspect(%{"category.fields" => category.fields})
    IO.inspect(%{"ad.fields" => ad.fields})

    attrs =
      cond do
        Enum.count(category.fields) < Enum.count(attrs["fields"]) ->
          Map.put(
            attrs,
            "fields",
            Enum.map(
              category.fields,
              fn field ->
                %{
                  "name" => field.name,
                  "type" => field.type,
                  "values" => field.values
                }
              end
            )
          )

        attrs["fields"] ->
          attrs
          |> Map.put(
            "fields",
            Enum.map(attrs["fields"], fn {k, v} ->
              field = Enum.at(category.fields, String.to_integer(k))

              %{
                "value" => v["value"],
                "name" => field.name,
                "type" => field.type,
                "values" => field.values
              }
            end)
          )

        is_list(ad.fields) ->
          Map.put(
            attrs,
            "fields",
            Enum.map(
              category.fields,
              fn field ->
                f = Enum.find(ad.fields, fn r -> r.name == field.name end)
                f = if f == nil, do: %{value: ""}, else: f

                %{
                  "value" => f.value,
                  "name" => field.name,
                  "type" => field.type,
                  "values" => field.values
                }
              end
            )
          )

        true ->
          Map.put(
            attrs,
            "fields",
            Enum.map(
              category.fields,
              fn field ->
                %{
                  "name" => field.name,
                  "type" => field.type,
                  "values" => field.values
                }
              end
            )
          )
      end

    ad
    |> cast(attrs, [:title, :description, :price, :city, :state])
    |> cast_embed(:fields)
    |> put_assoc(:images, images)
    |> put_assoc(:category, category)
    |> validate_required([:title, :price, :city, :state], message: "Obavezno polje")
  end
end
