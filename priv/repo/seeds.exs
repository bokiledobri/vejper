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
alias Vejper.Repo
alias Vejper.Chat

rooms = ["General", "Mods", "Attys"]

rooms = Enum.map(rooms, fn n -> %{"name" => n} end)

Enum.each(rooms, fn room -> Chat.create_room(room) end)
