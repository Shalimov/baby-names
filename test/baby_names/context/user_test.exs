defmodule BabyNames.Context.UserTest do
  import Ecto.Query
  use BabyNames.DataCase

  alias BabyNames.Repo
  alias BabyNames.Repo.{NameDescription, UserFavouriteNames, UserViewedNames}
  alias BabyNames.Context.{User, Accounts}

  setup do
    user_guid = Ecto.UUID.generate()

    {:ok, user} = Accounts.create_account(%{device_id: user_guid})
    name_desc = Repo.one(from(nd in NameDescription, limit: 1))

    [current_user: user, name_desc: name_desc]
  end

  test "should set user favourite names and avoid favourite names duplicates", context do
    user = context[:current_user]
    name = context[:name_desc]

    assert {:ok, true} = User.marked_name_as_favourite(user.id, name.id)

    saved_record = Repo.get_by(UserFavouriteNames, user_id: user.id, name_id: name.id)

    refute is_nil(saved_record)

    assert {:error, _, _, _} = User.marked_name_as_favourite(user.id, name.id)

    assert Repo.aggregate(from(ufn in UserFavouriteNames), :count, :id) == 1
  end

  test "should set user's fav names as well as mark it as viewed", context do
    user = context[:current_user]
    name = context[:name_desc]

    no_name_record = Repo.get_by(UserViewedNames, user_id: user.id, name_id: name.id)

    assert is_nil(no_name_record)

    assert {:ok, true} = User.marked_name_as_favourite(user.id, name.id)

    saved_record = Repo.get_by(UserViewedNames, user_id: user.id, name_id: name.id)

    refute is_nil(saved_record)
  end

  test "refuses to set user's fav name if name or user is not defined", context do
    user = context[:current_user]
    name = context[:name_desc]

    assert {:error, _, _, _} = User.marked_name_as_favourite(user.id, nil)
    assert {:error, _, _, _} = User.marked_name_as_favourite(user.id, 0)

    assert {:error, _, _, _} = User.marked_name_as_favourite(nil, name.id)
    assert {:error, _, _, _} = User.marked_name_as_favourite(0, name.id)

    assert {:error, _, _, _} = User.marked_name_as_favourite(nil, nil)
    assert {:error, _, _, _} = User.marked_name_as_favourite(0, 0)
  end

  test "should mark name only as viewed", context do
    user = context[:current_user]
    name = context[:name_desc]

    no_vie_name_record = Repo.get_by(UserViewedNames, user_id: user.id, name_id: name.id)
    no_fav_name_record = Repo.get_by(UserFavouriteNames, user_id: user.id, name_id: name.id)

    assert is_nil(no_vie_name_record) and is_nil(no_fav_name_record)

    assert {:ok, true} = User.marked_name_as_viewed(user.id, name.id)

    still_no_record = Repo.get_by(UserFavouriteNames, user_id: user.id, name_id: name.id)
    saved_record = Repo.get_by(UserViewedNames, user_id: user.id, name_id: name.id)

    assert is_nil(still_no_record)
    refute is_nil(saved_record)
  end

  test "refuses to set user's viewed name if name or user is not defined", context do
    user = context[:current_user]
    name = context[:name_desc]

    assert {:error, _} = User.marked_name_as_viewed(user.id, nil)
    assert {:error, _} = User.marked_name_as_viewed(user.id, 0)

    assert {:error, _} = User.marked_name_as_viewed(nil, name.id)
    assert {:error, _} = User.marked_name_as_viewed(0, name.id)

    assert {:error, _} = User.marked_name_as_viewed(nil, nil)
    assert {:error, _} = User.marked_name_as_viewed(0, 0)
  end
end
