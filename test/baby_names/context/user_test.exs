defmodule BabyNames.Context.UserTest do
  import Ecto.Query
  use BabyNames.DataCase

  alias BabyNames.Repo
  alias BabyNames.Repo.{NameDescription, UserFavouriteNames, UserViewedNames}
  alias BabyNames.Context.{User, Accounts, Collaboration}

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

  test "removal of favourite name, viewed name should be untouched", context do
    user = context[:current_user]
    name = context[:name_desc]

    assert {:ok, true} = User.marked_name_as_favourite(user.id, name.id)

    assert Repo.aggregate(from(ufn in UserFavouriteNames), :count, :id) == 1
    assert Repo.aggregate(from(uvn in UserViewedNames), :count, :id) == 1

    assert {:ok, _} = User.remove_favourite_name(user.id, name.id)

    assert Repo.aggregate(from(ufn in UserFavouriteNames), :count, :id) == 0
    assert Repo.aggregate(from(uvn in UserViewedNames), :count, :id) == 1
  end

  test "refuses removal of favourite name if args are invalid", context do
    user = context[:current_user]
    name = context[:name_desc]

    assert {:error, :not_found} = User.remove_favourite_name(user.id, nil)
    assert {:error, :not_found} = User.remove_favourite_name(user.id, 0)

    assert {:error, :not_found} = User.remove_favourite_name(nil, name.id)
    assert {:error, :not_found} = User.remove_favourite_name(0, name.id)

    assert {:error, :not_found} = User.remove_favourite_name(nil, nil)
    assert {:error, :not_found} = User.remove_favourite_name(0, 0)
  end

  test "returns unviewed names", context do
    user = context[:current_user]

    assert {:ok, first_names_set} =
             User.take_unviewed_names(user.id, %{
               filter: %{gender: "mixed"},
               limit: 5
             })

    assert {:ok, second_names_set} =
             User.take_unviewed_names(user.id, %{
               filter: %{gender: "mixed"},
               limit: 5
             })

    assert first_names_set == second_names_set

    [first_name | _rest] = first_names_set

    assert {:ok, true} = User.marked_name_as_viewed(user.id, first_name.id)

    assert {:ok, third_names_set} =
             User.take_unviewed_names(user.id, %{
               filter: %{gender: "mixed"},
               limit: 5
             })

    refute first_names_set == third_names_set
  end

  test "returns unviewed names by filter", context do
    user = context[:current_user]

    assert {:ok, female_names_set} =
             User.take_unviewed_names(user.id, %{
               filter: %{gender: "female"},
               limit: 5
             })

    assert {:ok, male_names_set} =
             User.take_unviewed_names(user.id, %{
               filter: %{gender: "male"},
               limit: 5
             })

    assert length(female_names_set) == 5
    assert length(male_names_set) == 5

    assert Enum.all?(female_names_set, &(&1.gender == "female")) == true
    assert Enum.all?(male_names_set, &(&1.gender == "male")) == true
  end

  test "returns user's fav names", context do
    user = context[:current_user]
    name = context[:name_desc]

    assert {:ok, fav_names} = User.take_favourite_names(user.id)
    assert length(fav_names) == 0

    assert {:ok, true} = User.marked_name_as_favourite(user.id, name.id)
    assert {:ok, fav_names} = User.take_favourite_names(user.id)
    assert length(fav_names) == 1

    assert {:ok, true} = User.remove_favourite_name(user.id, name.id)
    assert {:ok, fav_names} = User.take_favourite_names(user.id)
    assert length(fav_names) == 0
  end

  test "returns matches between connected users", context do
    holder_guid = Ecto.UUID.generate()

    owner = context[:current_user]
    name_desc = context[:name_desc]

    {:ok, holder} = Accounts.create_account(%{device_id: holder_guid})

    assert {:ok, token} = Collaboration.create_collaboration(owner.id)
    assert {:ok, true} = Collaboration.connect_collaboration(token, holder.id)

    assert {:ok, true} = User.marked_name_as_favourite(owner.id, name_desc.id)
    assert {:ok, true} = User.marked_name_as_favourite(holder.id, name_desc.id)

    assert {:ok, owner_matches} = User.take_matched_names(owner.id)
    assert {:ok, holder_matches} = User.take_matched_names(holder.id)

    assert owner_matches == holder_matches
    assert length(owner_matches) == 1
  end
end
