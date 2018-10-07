defmodule BabyNamesWeb.GraphQl.Types.User.Mutation do
  use Absinthe.Schema.Notation

  alias BabyNamesWeb.GraphQl.Resolvers.User

  object :user_mutations do
    field :create_user, :user do
      arg(:device_id, non_null(:id))

      resolve(&User.Mutation.create_user/2)
    end

    field :create_collaboration, :id do
      resolve(User.Mutation.resolve_by(:create_collaboration))
    end

    field :connect, :boolean do
      arg(:token, non_null(:string))

      resolve(User.Mutation.resolve_by(:connect))
    end

    field :disconnect, :boolean do
      arg(:token, non_null(:string))

      resolve(User.Mutation.resolve_by(:disconnect))
    end

    field :mark_name_as_viewed, :boolean do
      arg(:id, non_null(:id))

      resolve(User.Mutation.resolve_by(:mark_name_as_viewed))
    end

    field :remember_name, :boolean do
      arg(:id, non_null(:id))

      resolve(User.Mutation.resolve_by(:remember_name))
    end

    field :forget_name, :boolean do
      arg(:id, non_null(:id))

      resolve(User.Mutation.resolve_by(:forget_name))
    end
  end
end
