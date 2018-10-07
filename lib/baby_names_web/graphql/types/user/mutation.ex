defmodule BabyNamesWeb.GraphQl.Types.User.Mutation do
  use Absinthe.Schema.Notation

  alias BabyNamesWeb.GraphQl.Resolvers

  object :user_mutations do
    field :create_user, :user do
      arg(:device_id, non_null(:id))

      resolve(&Resolvers.User.Mutation.create_user/2)
    end

    field :create_collaboration, :id do
      resolve(&Resolvers.User.Mutation.create_collaboration/2)
    end

    field :connect, :boolean do
      arg(:token, non_null(:string))

      resolve(&Resolvers.User.Mutation.connect/2)
    end

    field :disconnect, :boolean do
      arg(:token, non_null(:string))

      resolve(&Resolvers.User.Mutation.disconnect/2)
    end

    field :mark_name_as_viewed, :boolean do
      arg(:id, non_null(:id))

      resolve(&Resolvers.User.Mutation.mark_name_as_viewed/2)
    end

    field :remember_name, :boolean do
      arg(:id, non_null(:id))

      resolve(&Resolvers.User.Mutation.mark_name_as_viewed/2)
    end

    field :forget_name, :boolean do
      arg(:id, non_null(:id))

      resolve(&Resolvers.User.Mutation.mark_name_as_viewed/2)
    end
  end
end
