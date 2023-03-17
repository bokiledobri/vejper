defmodule VejperWeb.AdLiveTest do
  use VejperWeb.ConnCase

  import Phoenix.LiveViewTest
  import Vejper.StoreFixtures

  @create_attrs %{city: "some city", description: "some description", fields: "some fields", price: 42, state: "some state", title: "some title"}
  @update_attrs %{city: "some updated city", description: "some updated description", fields: "some updated fields", price: 43, state: "some updated state", title: "some updated title"}
  @invalid_attrs %{city: nil, description: nil, fields: nil, price: nil, state: nil, title: nil}

  defp create_ad(_) do
    ad = ad_fixture()
    %{ad: ad}
  end

  describe "Index" do
    setup [:create_ad]

    test "lists all store_ads", %{conn: conn, ad: ad} do
      {:ok, _index_live, html} = live(conn, ~p"/store_ads")

      assert html =~ "Listing Store ads"
      assert html =~ ad.city
    end

    test "saves new ad", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/store_ads")

      assert index_live |> element("a", "New Ad") |> render_click() =~
               "New Ad"

      assert_patch(index_live, ~p"/store_ads/new")

      assert index_live
             |> form("#ad-form", ad: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#ad-form", ad: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/store_ads")

      html = render(index_live)
      assert html =~ "Ad created successfully"
      assert html =~ "some city"
    end

    test "updates ad in listing", %{conn: conn, ad: ad} do
      {:ok, index_live, _html} = live(conn, ~p"/store_ads")

      assert index_live |> element("#store_ads-#{ad.id} a", "Edit") |> render_click() =~
               "Edit Ad"

      assert_patch(index_live, ~p"/store_ads/#{ad}/edit")

      assert index_live
             |> form("#ad-form", ad: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#ad-form", ad: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/store_ads")

      html = render(index_live)
      assert html =~ "Ad updated successfully"
      assert html =~ "some updated city"
    end

    test "deletes ad in listing", %{conn: conn, ad: ad} do
      {:ok, index_live, _html} = live(conn, ~p"/store_ads")

      assert index_live |> element("#store_ads-#{ad.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#store_ads-#{ad.id}")
    end
  end

  describe "Show" do
    setup [:create_ad]

    test "displays ad", %{conn: conn, ad: ad} do
      {:ok, _show_live, html} = live(conn, ~p"/store_ads/#{ad}")

      assert html =~ "Show Ad"
      assert html =~ ad.city
    end

    test "updates ad within modal", %{conn: conn, ad: ad} do
      {:ok, show_live, _html} = live(conn, ~p"/store_ads/#{ad}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Ad"

      assert_patch(show_live, ~p"/store_ads/#{ad}/show/edit")

      assert show_live
             |> form("#ad-form", ad: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#ad-form", ad: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/store_ads/#{ad}")

      html = render(show_live)
      assert html =~ "Ad updated successfully"
      assert html =~ "some updated city"
    end
  end
end
