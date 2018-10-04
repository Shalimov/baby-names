defmodule BabyNamesWeb.GraphQl.Schema do
  use Absinthe.Schema
  alias BabyNamesWeb.GraphQl.Types

  # import absinthe builtin date type
  import_types Absinthe.Type.Custom

  # User related types
  import_types Types.User.Types
  import_types Types.User.Query
  import_types Types.User.Mutation

  # NameDescription realted types
  import_types Types.NameDescription.Types
  import_types Types.NameDescription.Query

  query do
    import_fields :user_queries
    import_fields :name_description_queries
  end

  mutation do
    import_fields :user_mutations
  end
end
