defmodule BabyNames.Context.CollaborationTest do
  use BabyNames.DataCase

  # import Ecto.Query, only: [from: 2]
  # alias BabyNames.Repo
  # alias BabyNames.Repo
  alias BabyNames.Context.{Collaboration, Accounts}

  test "crates collaboration without holder and returns UUIDv4 token" do
    fake_device_id = Ecto.UUID.generate()

    assert {:ok, owner} = Accounts.create_account(%{device_id: fake_device_id})
    assert {:ok, token} = Collaboration.create_collaboration(owner.id)
  end

  test "returns collaboration token if collaboration has already been created for specific owner" do
    fake_device_id = Ecto.UUID.generate()

    assert {:ok, owner} = Accounts.create_account(%{device_id: fake_device_id})
    assert {:ok, owner_token} = Collaboration.create_collaboration(owner.id)
    assert {:ok, owner_next_token} = Collaboration.create_collaboration(owner.id)

    assert owner_token == owner_next_token
  end

  test "refuses collaboration creation if user id isn't defined" do
    assert {:error, :owner_not_found} = Collaboration.create_collaboration(nil)
    assert {:error, changset} = Collaboration.create_collaboration(0)

    {message, _} = Keyword.get(changset.errors, :owner_id)

    assert message == "owner doesn't exist"
  end

  test "removes user collaboration " do
    fake_device_id = Ecto.UUID.generate()

    assert {:ok, owner} = Accounts.create_account(%{device_id: fake_device_id})
    assert {:ok, token} = Collaboration.create_collaboration(owner.id)

    assert {:ok, _} = Collaboration.remove_collaboration(owner.id, token)
  end

  test "refuses to remove user collaboration if user isn't owner" do
    fake_device_id = Ecto.UUID.generate()
    fake_other_device_id = Ecto.UUID.generate()

    assert {:ok, owner} = Accounts.create_account(%{device_id: fake_device_id})
    assert {:ok, not_owner} = Accounts.create_account(%{device_id: fake_other_device_id})
    assert {:ok, token} = Collaboration.create_collaboration(owner.id)


    assert {:error, _} = Collaboration.remove_collaboration(not_owner.id, token)
  end

  test "refuses to remove user collaboration if user isn't passed or exists" do
    fake_device_id = Ecto.UUID.generate()
    fake_other_device_id = Ecto.UUID.generate()

    assert {:ok, owner} = Accounts.create_account(%{device_id: fake_device_id})
    assert {:ok, not_owner} = Accounts.create_account(%{device_id: fake_other_device_id})
    assert {:ok, token} = Collaboration.create_collaboration(owner.id)


    assert {:error, _} = Collaboration.remove_collaboration(not_owner.id, token)
    assert {:error, _} = Collaboration.remove_collaboration(nil, token)
    assert {:error, _} = Collaboration.remove_collaboration(nil, nil)
    assert {:error, _} = Collaboration.remove_collaboration(owner.id, nil)
  end
end
