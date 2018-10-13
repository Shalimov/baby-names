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

  test "refuses collaboration creation if user id isn't defined or exist" do
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

  test "connects user as holder to existing collaboration" do
    fake_device_id = Ecto.UUID.generate()
    fake_other_device_id = Ecto.UUID.generate()

    assert {:ok, owner} = Accounts.create_account(%{device_id: fake_device_id})
    assert {:ok, holder} = Accounts.create_account(%{device_id: fake_other_device_id})
    assert {:ok, token} = Collaboration.create_collaboration(owner.id)

    assert {:ok, true} = Collaboration.connect_collaboration(token, holder.id)
  end

  test "refuses to connect user if holder already exists" do
    fake_device_id = Ecto.UUID.generate()
    fake_holder_device_id = Ecto.UUID.generate()
    fake_other_device_id = Ecto.UUID.generate()

    assert {:ok, owner} = Accounts.create_account(%{device_id: fake_device_id})
    assert {:ok, holder} = Accounts.create_account(%{device_id: fake_holder_device_id})
    assert {:ok, tester} = Accounts.create_account(%{device_id: fake_other_device_id})
    assert {:ok, token} = Collaboration.create_collaboration(owner.id)

    assert {:ok, true} = Collaboration.connect_collaboration(token, holder.id)
    assert {:error, :holder_exists} = Collaboration.connect_collaboration(token, tester.id)
  end

  test "refuses to connect user if he's owner of collaboration" do
    fake_device_id = Ecto.UUID.generate()

    assert {:ok, owner} = Accounts.create_account(%{device_id: fake_device_id})
    assert {:ok, token} = Collaboration.create_collaboration(owner.id)

    assert {:error, :holder_is_owner} = Collaboration.connect_collaboration(token, owner.id)
  end

  test "refuses to connect user if he's already bound" do
    fake_device_id = Ecto.UUID.generate()
    fake_holder_device_id = Ecto.UUID.generate()
    fake_other_device_id = Ecto.UUID.generate()

    assert {:ok, owner} = Accounts.create_account(%{device_id: fake_device_id})
    assert {:ok, holder} = Accounts.create_account(%{device_id: fake_holder_device_id})
    assert {:ok, tester} = Accounts.create_account(%{device_id: fake_other_device_id})
    assert {:ok, token} = Collaboration.create_collaboration(owner.id)
    assert {:ok, tester_col_token} = Collaboration.create_collaboration(tester.id)

    assert {:ok, true} = Collaboration.connect_collaboration(token, holder.id)

    assert {:error, :holder_bound} =
             Collaboration.connect_collaboration(tester_col_token, holder.id)
  end

  test "refuses to connect user if holder id is invalid or nil" do
    fake_device_id = Ecto.UUID.generate()

    assert {:ok, owner} = Accounts.create_account(%{device_id: fake_device_id})
    assert {:ok, token} = Collaboration.create_collaboration(owner.id)

    assert {:error, _} = Collaboration.connect_collaboration(token, 0)
    assert {:error, _} = Collaboration.connect_collaboration(token, nil)
  end

  test "refuses to connect user if token is invalid or nil" do
    token = Ecto.UUID.generate()
    fake_device_id = Ecto.UUID.generate()

    assert {:ok, owner} = Accounts.create_account(%{device_id: fake_device_id})

    assert {:error, :not_found} = Collaboration.connect_collaboration(token, owner.id)
    assert {:error, :not_found} = Collaboration.connect_collaboration(nil, owner.id)
    assert {:error, :not_found} = Collaboration.connect_collaboration(nil, nil)
  end

  test "returns collaboration token for holder or owner" do
    owner_device_id = Ecto.UUID.generate()
    holder_device_id = Ecto.UUID.generate()

    assert {:ok, owner} = Accounts.create_account(%{device_id: owner_device_id})
    assert {:ok, holder} = Accounts.create_account(%{device_id: holder_device_id})
    assert {:ok, token} = Collaboration.create_collaboration(owner.id)

    assert {:ok, true} = Collaboration.connect_collaboration(token, holder.id)

    found_token_h = Collaboration.get_collaboration_token(holder.id)
    found_token_o = Collaboration.get_collaboration_token(owner.id)

    assert found_token_h == found_token_o
    assert found_token_h == token
  end

  test "refuses to return collaboration token if user doesn't exist" do
    found_token_h = Collaboration.get_collaboration_token(0)
    found_token_o = Collaboration.get_collaboration_token(nil)

    assert found_token_h == nil
    assert found_token_o == nil
  end
end
