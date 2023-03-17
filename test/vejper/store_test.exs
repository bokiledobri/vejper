defmodule Vejper.StoreTest do
  use Vejper.DataCase

  alias Vejper.Store

  describe "store_ads" do
    alias Vejper.Store.Ad

    import Vejper.StoreFixtures

    @invalid_attrs %{city: nil, description: nil, fields: nil, price: nil, state: nil, title: nil}

    test "list_store_ads/0 returns all store_ads" do
      ad = ad_fixture()
      assert Store.list_store_ads() == [ad]
    end

    test "get_ad!/1 returns the ad with given id" do
      ad = ad_fixture()
      assert Store.get_ad!(ad.id) == ad
    end

    test "create_ad/1 with valid data creates a ad" do
      valid_attrs = %{city: "some city", description: "some description", fields: "some fields", price: 42, state: "some state", title: "some title"}

      assert {:ok, %Ad{} = ad} = Store.create_ad(valid_attrs)
      assert ad.city == "some city"
      assert ad.description == "some description"
      assert ad.fields == "some fields"
      assert ad.price == 42
      assert ad.state == "some state"
      assert ad.title == "some title"
    end

    test "create_ad/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Store.create_ad(@invalid_attrs)
    end

    test "update_ad/2 with valid data updates the ad" do
      ad = ad_fixture()
      update_attrs = %{city: "some updated city", description: "some updated description", fields: "some updated fields", price: 43, state: "some updated state", title: "some updated title"}

      assert {:ok, %Ad{} = ad} = Store.update_ad(ad, update_attrs)
      assert ad.city == "some updated city"
      assert ad.description == "some updated description"
      assert ad.fields == "some updated fields"
      assert ad.price == 43
      assert ad.state == "some updated state"
      assert ad.title == "some updated title"
    end

    test "update_ad/2 with invalid data returns error changeset" do
      ad = ad_fixture()
      assert {:error, %Ecto.Changeset{}} = Store.update_ad(ad, @invalid_attrs)
      assert ad == Store.get_ad!(ad.id)
    end

    test "delete_ad/1 deletes the ad" do
      ad = ad_fixture()
      assert {:ok, %Ad{}} = Store.delete_ad(ad)
      assert_raise Ecto.NoResultsError, fn -> Store.get_ad!(ad.id) end
    end

    test "change_ad/1 returns a ad changeset" do
      ad = ad_fixture()
      assert %Ecto.Changeset{} = Store.change_ad(ad)
    end
  end
end
