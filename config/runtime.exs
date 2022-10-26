import Config

config :stonks,
  marketstack_api_key: System.fetch_env!("MARKETSTACK_API_KEY") || ""
