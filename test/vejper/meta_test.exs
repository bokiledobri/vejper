defmodule Vejper.MetaTest do
  use Vejper.DataCase

  alias Vejper.Meta

  describe "user_counts" do
    alias Vejper.Meta.UserCount

    import Vejper.MetaFixtures

    @invalid_attrs %{count: nil}

    test "list_user_counts/0 returns all user_counts" do
      user_count = user_count_fixture()
      assert Meta.list_user_counts() == [user_count]
    end

    test "get_user_count!/1 returns the user_count with given id" do
      user_count = user_count_fixture()
      assert Meta.get_user_count!(user_count.id) == user_count
    end

    test "create_user_count/1 with valid data creates a user_count" do
      valid_attrs = %{count: 42}

      assert {:ok, %UserCount{} = user_count} = Meta.create_user_count(valid_attrs)
      assert user_count.count == 42
    end

    test "create_user_count/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Meta.create_user_count(@invalid_attrs)
    end

    test "update_user_count/2 with valid data updates the user_count" do
      user_count = user_count_fixture()
      update_attrs = %{count: 43}

      assert {:ok, %UserCount{} = user_count} = Meta.update_user_count(user_count, update_attrs)
      assert user_count.count == 43
    end

    test "update_user_count/2 with invalid data returns error changeset" do
      user_count = user_count_fixture()
      assert {:error, %Ecto.Changeset{}} = Meta.update_user_count(user_count, @invalid_attrs)
      assert user_count == Meta.get_user_count!(user_count.id)
    end

    test "delete_user_count/1 deletes the user_count" do
      user_count = user_count_fixture()
      assert {:ok, %UserCount{}} = Meta.delete_user_count(user_count)
      assert_raise Ecto.NoResultsError, fn -> Meta.get_user_count!(user_count.id) end
    end

    test "change_user_count/1 returns a user_count changeset" do
      user_count = user_count_fixture()
      assert %Ecto.Changeset{} = Meta.change_user_count(user_count)
    end
  end
end
