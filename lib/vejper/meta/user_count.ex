defmodule Vejper.Meta.UserCount do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_counts" do
    field :count, :integer

    timestamps()
  end

  @doc false
  def changeset(user_count, attrs) do
    user_count
    |> cast(attrs, [:count])
    |> validate_required([:count])
  end
end
