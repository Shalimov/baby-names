defmodule BabyNamesWeb.GraphQl.Types.User.Mutation do
  use Absinthe.Schema.Notation

  alias BabyNamesWeb.GraphQl.Resolvers

  object :user_mutations do
    field :create_user, :user do
      arg :device_id, non_null(:id)

      resolve &Resolvers.User.Mutation.create_user/2
    end
  end
end
