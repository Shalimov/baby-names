defmodule BabyNamesWeb.GraphQl.Types.NameDescription.Query do
  use Absinthe.Schema.Notation

  alias BabyNamesWeb.GraphQl.Resolvers.NameDescription

  object :name_description_queries do
    field :name_description, :name_description do
      arg :id, non_null(:id)

      resolve &NameDescription.Query.name_description/2
    end

    field :unviewed_name_descriptions, list_of(non_null(:name_description)) do
      arg :input, non_null(:unviewed_name_description_query_input)

      resolve &NameDescription.Query.unviewed_name_descriptions/2
    end
  end
end
