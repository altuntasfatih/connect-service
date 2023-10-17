import Config

config :connect_service, Oban, testing: :manual

config :connect_service, ConnectService.Repo,
  username: "postgres",
  password: "postgres",
  database: "connect_service_test",
  hostname: "localhost",
  port: 5433,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
