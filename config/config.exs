# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :dmage, DmageWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nc9/zHxAL/eCWKNA2xgeXxRGgABM3MpaAa8C96f8DmJQUBCXvH6Ec8mcPL842lxe",
  render_errors: [view: DmageWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Dmage.PubSub,
  live_view: [signing_salt: "ugUbCH1W"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
