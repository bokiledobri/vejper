defmodule Vejper.Accounts.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "profiles" do
    field :city, :string
    field :username, :string
    field :date_of_birth, :date
    field :age, :integer, virtual: true
    belongs_to :image, Vejper.Media.Image, on_replace: :nilify
    belongs_to :user, Vejper.Accounts.User

    timestamps()
  end

  @doc false
  def user_changeset(%Vejper.Accounts.User{} = user, attrs, image) do
    user
    |> Ecto.build_assoc(:profile)
    |> changeset(attrs, image)
  end

  def changeset(profile, attrs, image) do
    profile
    |> cast(attrs, [:username, :city, :date_of_birth])
    |> validate_required([:username], message: "obavezno polje")
    |> unsafe_validate_unique(:username, Vejper.Repo, message: "korisničko ime je već u upotrebi")
    |> unique_constraint(:username, message: "korisničko ime je već u upotrebi")
    |> validate_xrated()
    |> put_assoc(:image, image)
  end

  def validate_xrated(changeset) do
    validate_change(changeset, :date_of_birth, fn :date_of_birth, dob ->
      if calculate_age(dob) < 18 do
        [date_of_birth: "Imate manje od 18 godina"]
      else
        []
      end
    end)
  end

  defp calculate_age(dob) do
    today = Date.utc_today()
    {:ok, today_in_birthday_year} = Date.new(dob.year, today.month, today.day)
    years_diff = today.year - dob.year

    if Date.compare(today_in_birthday_year, dob) == :lt do
      years_diff - 1
    else
      years_diff
    end
  end

  def get_profile_age(%Vejper.Accounts.Profile{} = profile) do
    Map.put(profile, :age, calculate_age(profile.date_of_birth))
  end
end
