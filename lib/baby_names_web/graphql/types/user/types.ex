defmodule BabyNamesWeb.GraphQl.Types.User.Types do
  use Absinthe.Schema.Notation

  object :user do
    field :id, non_null(:id)
    field :device_id, non_null(:id)
    field :bound, :boolean
    field :collaboration_token, :id
  end
end
