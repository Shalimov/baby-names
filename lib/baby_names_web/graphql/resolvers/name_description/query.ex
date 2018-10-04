defmodule BabyNamesWeb.GraphQl.Resolvers.NameDescription.Query do
  @moduledoc """
  Simple query set for name description data model
  """

  alias BabyNames.Context.{User, NameOperations}

  def name_description(%{id: id}, _) do
    NameOperations.get_name_description(id)
  end

  def unviewed_name_descriptions(%{input: input}, %{context: context}) do
    user = Map.get(context, :current_user)
    User.take_unviewed_names(user.id, input)
  end
end
