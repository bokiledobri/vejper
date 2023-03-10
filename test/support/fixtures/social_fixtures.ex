defmodule Vejper.SocialFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Vejper.Social` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body",
        title: "some title"
      })
      |> Vejper.Social.create_post()

    post
  end
end
