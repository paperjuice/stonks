import Config

# TODO: add this to container env variables
# config :logger, :console,
# format: "[$level] $message $metadata\n",
# metadata: [:error_code, :file]

config :logger, level: :info, truncate: :infinity

config :stonks,
  http_client: Stonks.Integration.Shared.Http,
  marketstack: Stonks.Integration.Marketstack,
  storage: Stonks.Storage

config :stonks, :port, System.get_env("PORT") || "9900"


import_config "#{Mix.env()}.exs"
