# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :baby_names,
  ecto_repos: [BabyNames.Repo]

# Configures the endpoint
config :baby_names, BabyNamesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Qp+T+s/R8DDPWwyyW+sLrll2p40zT1pzixS0UdHQvt5bgi0k+Calp1T7y0Ui0OoM",
  render_errors: [view: BabyNamesWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: BabyNames.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
