defmodule BabyNames.Context.AccountsTest do
  use BabyNames.DataCase

  alias BabyNames.Context.Accounts

  test "accepts device_id and creates new user" do
    {:ok, user} = Accounts.create_account(%{device_id: "xxxx-xxxx-xxxx-xxxx"})

    refute is_nil(user.id)
  end

  test "returns error when device id is not set" do
    {:error, changset} = Accounts.create_account(%{device_id: nil})

    assert errors_on(changset) == %{device_id: ["can't be blank"]}
  end

  test "accepts only device_id and skips all other unspecified attrs" do
    {:ok, user} =
      Accounts.create_account(%{device_id: "xxxx-yyyy-yyyy-xxxx", new_prop: 1, new_prop_two: 2})

    refute Map.get(user, :new_prop)
    refute Map.get(user, :new_prop_two)
  end

  test "accepts device_id and returns existing user if exists, else nil" do
    {:ok, created_user} = Accounts.create_account(%{device_id: "xxxx-yyyy-yyyy-xxxx"})
    expected_user = Accounts.get_by_device_id(created_user.device_id)
    expected_not_found = Accounts.get_by_device_id("----x----x----")

    assert elem(expected_user, 0) == :ok
    assert elem(expected_user, 1)

    assert expected_not_found == {:error, :not_found}
  end
end
