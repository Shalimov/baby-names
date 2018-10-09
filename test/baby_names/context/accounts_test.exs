defmodule BabyNames.Context.AccountsTest do
  use BabyNames.DataCase

  alias BabyNames.Context.Accounts

  test "accepts device_id and creates new user" do
    assert {:ok, user} = Accounts.create_account(%{device_id: "xxxx-xxxx-xxxx-xxxx"})
    refute is_nil(user.id)
  end

  test "returns error when device id is not set" do
    assert {:error, changset} = Accounts.create_account(%{device_id: nil})
    assert errors_on(changset) == %{device_id: ["can't be blank"]}
  end

  test "accepts only device_id and skips all other unspecified attrs" do
    assert {:ok, user} =
      Accounts.create_account(%{device_id: "xxxx-yyyy-yyyy-xxxx", new_prop: 1, new_prop_two: 2})

    refute Map.get(user, :new_prop)
    refute Map.get(user, :new_prop_two)
  end

  test "accepts device_id and returns existing user if exists, else nil" do
    assert {:ok, created_user} = Accounts.create_account(%{device_id: "xxxx-yyyy-yyyy-xxxx"})
    assert {:ok, user} = Accounts.get_by_device_id(created_user.device_id)
    assert {:error, :not_found} = Accounts.get_by_device_id("--#{user.device_id}--")
  end
end
