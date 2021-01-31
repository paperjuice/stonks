import Config

# TODO: add this to container env variables
config :logger, :console,
  format: "[$level] $message $metadata\n",
  metadata: [:error_code, :file]

import_config "#{Mix.env()}.exs"
