ExUnit.start()

Mox.defmock(Stonks.Integration.Shared.HttpMock, for: Stonks.Integration.Shared.Http)
Mox.defmock(Stonks.Integration.MarketstackMock, for: Stonks.Integration.Marketstack)
Mox.defmock(Stonks.StorageMock, for: Stonks.Storage)
