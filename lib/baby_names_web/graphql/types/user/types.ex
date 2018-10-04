defmodule BabyNamesWeb.GraphQl.Types.User.Types do
  use Absinthe.Schema.Notation

  alias BabyNamesWeb.GraphQl.Resolvers

  object :user do
    field(:id, non_null(:id))
    field(:device_id, non_null(:id))
    field(:favourite_names, list_of(:name_description),
      resolve: &Resolvers.User.Types.favourite_names/3
    )
    field(:matched_names, list_of(:name_description),
      resolve: &Resolvers.User.Types.matched_names/3
    )
    field(:bound, :boolean, resolve: fn _, _ -> {:ok, true} end)
    field(:collaboration_token, :id, resolve: fn _, _ -> {:ok, "xxxx-xxx-xxx-xxxx"} end)
  end
end
