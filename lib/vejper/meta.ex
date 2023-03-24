defmodule Vejper.Meta do
  @moduledoc """
  The Meta context.
  """

  import Ecto.Query, warn: false
  alias Vejper.Repo

  alias Vejper.Meta.UserCount

  @doc """
  Returns the list of user_counts.

  ## Examples

      iex> list_user_counts()
      [%UserCount{}, ...]

  """
  def list_user_counts do
    Repo.all(UserCount)
  end

  @doc """
  Gets a single user_count.

  Raises `Ecto.NoResultsError` if the User count does not exist.

  ## Examples

      iex> get_user_count!(123)
      %UserCount{}

      iex> get_user_count!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_count!(id), do: Repo.get!(UserCount, id)

  @doc """
  Creates a user_count.

  ## Examples

      iex> create_user_count(%{field: value})
      {:ok, %UserCount{}}

      iex> create_user_count(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_count(attrs \\ %{}) do
    %UserCount{}
    |> UserCount.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_count.

  ## Examples

      iex> update_user_count(user_count, %{field: new_value})
      {:ok, %UserCount{}}

      iex> update_user_count(user_count, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_count(%UserCount{} = user_count, attrs) do
    user_count
    |> UserCount.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_count.

  ## Examples

      iex> delete_user_count(user_count)
      {:ok, %UserCount{}}

      iex> delete_user_count(user_count)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_count(%UserCount{} = user_count) do
    Repo.delete(user_count)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_count changes.

  ## Examples

      iex> change_user_count(user_count)
      %Ecto.Changeset{data: %UserCount{}}

  """
  def change_user_count(%UserCount{} = user_count, attrs \\ %{}) do
    UserCount.changeset(user_count, attrs)
  end
end
