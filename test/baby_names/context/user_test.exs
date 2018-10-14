defmodule BabyNames.Context.UserTest do
  import Ecto.Query
  use BabyNames.DataCase

  alias BabyNames.Repo
  alias BabyNames.Repo.{NameDescription, UserFavouriteNames}
  alias BabyNames.Context.{User, Accounts}

  setup do
    user_guid = Ecto.UUID.generate()
    {:ok, user} = Accounts.create_account(%{device_id: user_guid})
    [current_user: user]
  end

  test "should set user favourite names and avoid favourite names duplicates", context do
    user = context[:current_user]

    name = Repo.one(from(nd in NameDescription, limit: 1))

    assert {:ok, true} = User.marked_name_as_favourite(user.id, name.id)

    saved_record = Repo.get_by(UserFavouriteNames, user_id: user.id, name_id: name.id)

    refute is_nil(saved_record)

    assert {:error, _, _, _} = User.marked_name_as_favourite(user.id, name.id)

    assert Repo.aggregate(from(ufn in UserFavouriteNames), :count, :id) == 1
  end
end
