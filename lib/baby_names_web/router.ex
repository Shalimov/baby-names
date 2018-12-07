defmodule BabyNamesWeb.Router do
  use BabyNamesWeb, :router

  pipeline :graphql do
    plug(BabyNamesWeb.Context)
  end

  scope "/" do
    pipe_through(:graphql)

    forward("/graphql", Absinthe.Plug, schema: BabyNamesWeb.GraphQl.Schema)
    forward("/graphiql", Absinthe.Plug.GraphiQL, schema: BabyNamesWeb.GraphQl.Schema)
    get("/version", BabyNamesWeb.VersionController, :info)
  end
end
