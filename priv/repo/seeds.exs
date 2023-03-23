# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Vejper.Repo.insert!(%Vejper.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Vejper.Meta.Lists
alias Vejper.Accounts
alias Vejper.{Repo, Store}
alias Vejper.Store.{Ad, Category}
alias Vejper.Accounts.User
ExUnit.start()
Faker.start()

Enum.each(1..50, fn _ ->
  title = Faker.Commerce.product_name()
  description = Faker.Lorem.paragraph(2..20)
  images = Enum.map(1..3, fn _ -> Faker.Avatar.image_url() |> Vejper.Media.upload_image() end)
  images = Enum.map(images, fn {:ok, image} -> image end)
  state = Enum.random(Repo.get!(Lists, "ad_states").items)

  price = Enum.random(3..300) * 100
  city = Enum.random(Repo.get!(Lists, "cities").items)
  user_id = Enum.random([1, 2])
  category_id = Enum.random([1, 2, 3])
  category = Store.get_category!(category_id)

  ad = %{
    "title" => title,
    "description" => description,
    "state" => state,
    "price" => price,
    "city" => city
  }

  Store.create_ad(user_id, ad, category, images)
end)
