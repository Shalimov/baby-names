defmodule BabyNamesWeb.GraphQl.Types.User.Query do
  use Absinthe.Schema.Notation

  alias BabyNamesWeb.GraphQl.Resolvers

  object :user_queries do
    field :me, :user do
      resolve &Resolvers.User.Query.me/2
    end
  end
end
