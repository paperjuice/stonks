import Config

config :stonks,
  http_client: Stonks.Integration.Shared.HttpMock,
  marketstack: Stonks.Integration.MarketstackMock,
  storage: Stonks.StorageMock
