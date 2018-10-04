defmodule BabyNamesWeb.GraphQl.Types.NameDescription.Types do
  use Absinthe.Schema.Notation

  @desc "Gender enum definition"
  enum :gender do
    value(:male, as: "male")
    value(:female, as: "female")
    value(:mixed, as: "mixed")
  end

  @desc "Name Description schema"
  object :name_description do
    field(:id, non_null(:id))
    field(:name, non_null(:string))
    field(:description, non_null(:string))
    field(:gender, non_null(:gender))

    # original list shouldn't be blank
    field(:origin, list_of(:string))
    field(:name_dates, list_of(:string))
    field(:short_forms, list_of(:string))
  end

  @desc "Name Description Filter Input schema"
  input_object :name_description_filter_input do
    field(:gender, non_null(:gender))
  end

  @desc "Unviewed Name Description Input schema"
  input_object :unviewed_name_description_query_input do
    field(:limit, non_null(:integer))
    field(:filter, non_null(:name_description_filter_input))
  end
end
