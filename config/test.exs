use Mix.Config

config :fuelsystem, TestFilesystem,
  adapter: Fuelsystem.Adapters.LocalAdapter,
  root: "test/fixtures"
