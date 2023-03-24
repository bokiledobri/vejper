defmodule Vejper.MetaFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Vejper.Meta` context.
  """

  @doc """
  Generate a user_count.
  """
  def user_count_fixture(attrs \\ %{}) do
    {:ok, user_count} =
      attrs
      |> Enum.into(%{
        count: 42
      })
      |> Vejper.Meta.create_user_count()

    user_count
  end
end
