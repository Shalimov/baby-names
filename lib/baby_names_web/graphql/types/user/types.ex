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

    field(:bound, :boolean, resolve: &Resolvers.User.Types.bound?/3)
    field(:collaboration_token, :id, resolve: &Resolvers.User.Types.collaboration_token/3)
  end
end
