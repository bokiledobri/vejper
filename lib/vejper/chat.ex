defmodule Vejper.Chat do
  @moduledoc """
  The Chat context.
  """

  import Ecto.Query, warn: false
  alias Vejper.Repo

  alias Vejper.Chat.Room
  alias Vejper.Chat.Message

  @doc """
  Returns the list of chat_rooms.

  ## Examples

      iex> list_chat_rooms()
      [%Room{}, ...]

  """
  def list_rooms do
    Repo.all(Room)
  end

  @doc """
  Gets a single room.

  Raises `Ecto.NoResultsError` if the Room does not exist.

  ## Examples

      iex> get_room!(123)
      %Room{}

      iex> get_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_room!(id) do
    from(r in Room,
      as: :room,
      where: r.id == ^id,
      group_by: r.id
    )
    |> Repo.one()
  end

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:room_created, :all)
  end

  @doc """
  Updates a room.

  ## Examples

      iex> update_room(room, %{field: new_value})
      {:ok, %Room{}}

      iex> update_room(room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
    |> broadcast(:room_updated, :all)
  end

  @doc """
  Deletes a room.

  ## Examples

      iex> delete_room(room)
      {:ok, %Room{}}

      iex> delete_room(room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room(%Room{} = room) do
    Repo.delete(room)
    broadcast({:ok, room}, :room_deleted, :all)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(room)
      %Ecto.Changeset{data: %Room{}}

  """
  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  def create_message(%Room{} = room, %Vejper.Accounts.User{} = user, attrs) do
    room
    |> Ecto.build_assoc(:messages)
    |> Message.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
    |> broadcast(:message_sent)
  end

  def delete_message(room_id, message_id) do
    Repo.update_all(from(m in Message, where: m.id == ^message_id), set: [state: "deleted"])
    broadcast({:ok, get_room!(room_id)}, :post_updated)
  end

  def list_messages(room_id) do
    from(m in Message,
      where: m.room_id == ^room_id,
      order_by: [desc: :inserted_at],
      preload: [user: :profile]
    )
    |> Repo.all()
  end

  def change_message(%Message{} = room, attrs \\ %{}) do
    Message.changeset(room, attrs)
  end

  def subscribe(id) when is_integer(id) do
    Phoenix.PubSub.subscribe(Vejper.PubSub, "room-" <> Integer.to_string(id))
  end

  def subscribe(id) when is_bitstring(id) do
    Phoenix.PubSub.subscribe(Vejper.PubSub, "room-" <> id)
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(Vejper.PubSub, "rooms")
  end

  defp broadcast({:error, _} = error, _), do: error

  defp broadcast({:ok, %Room{} = room} = return, event) do
    Phoenix.PubSub.broadcast(Vejper.PubSub, "room-" <> Integer.to_string(room.id), {event, room})
    return
  end

  defp broadcast({:ok, %Message{} = message} = return, event) do
    Phoenix.PubSub.broadcast(
      Vejper.PubSub,
      "room-" <> Integer.to_string(message.room_id),
      {event, message}
    )

    return
  end

  defp broadcast({:error, _} = error, _, :all), do: error

  defp broadcast({:ok, item} = return, event, :all) do
    Phoenix.PubSub.broadcast(Vejper.PubSub, "rooms", {event, item})
    return
  end
end
