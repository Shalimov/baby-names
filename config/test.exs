use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :baby_names, BabyNamesWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :baby_names, BabyNames.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "baby_names_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
