defmodule Vejper.MediaFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Vejper.Media` context.
  """

  @doc """
  Generate a image.
  """
  def image_fixture(attrs \\ %{}) do
    {:ok, image} =
      attrs
      |> Enum.into(%{
        height: 42,
        public_id: "some public_id",
        url: "some url",
        width: 42
      })
      |> Vejper.Media.create_image()

    image
  end
end
