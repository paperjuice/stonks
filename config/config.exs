import Config

# TODO: add this to container env variables
config :logger, :console,
  format: "[$level] $message $metadata\n",
  metadata: [:error_code, :file]

config :stonks,
  http_client: Stonks.Integration.Shared.Http,
  marketstack: Stonks.Integration.Marketstack,
  storage: Stonks.Storage

import_config "#{Mix.env()}.exs"
