defmodule BabyNames.Context.NameOperationsTest do
  use BabyNames.DataCase

  import Ecto.Query, only: [from: 2]
  alias BabyNames.Repo
  alias BabyNames.Repo.NameDescription
  alias BabyNames.Context.NameOperations

  test "accepts name description id and returns name if it's found otherwise nil" do
    expected_items = Repo.all(from(nd in NameDescription, select: nd, limit: 10))

    actual_items =
      for item <- expected_items do
        NameOperations.get_name_description(item.id)
      end

    assert actual_items == expected_items
  end
end
