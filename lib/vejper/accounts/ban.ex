defmodule Vejper.Accounts.Ban do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bans" do
    field :type, :string
    field :until, :naive_datetime
    belongs_to :banned, Vejper.Accounts.User, on_replace: :delete
    belongs_to :by, Vejper.Accounts.User, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(ban, attrs, banned, by) do
    IO.inspect(banned)

    ban
    |> cast(attrs, [:until, :type])
    |> validate_required([:until, :type])
    |> unique_constraint([:banned_id, :type])
    |> put_assoc(:banned, banned)
    |> put_assoc(:by, by)
  end
end
