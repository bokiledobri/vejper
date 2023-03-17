defmodule Vejper.StoreFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Vejper.Store` context.
  """

  @doc """
  Generate a ad.
  """
  def ad_fixture(attrs \\ %{}) do
    {:ok, ad} =
      attrs
      |> Enum.into(%{
        city: "some city",
        description: "some description",
        fields: "some fields",
        price: 42,
        state: "some state",
        title: "some title"
      })
      |> Vejper.Store.create_ad()

    ad
  end
end
