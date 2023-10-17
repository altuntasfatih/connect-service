import Config

config :connect_service, ConnectService.Repo,
  username: "postgres",
  password: "postgres",
  database: "connect_service",
  hostname: "localhost",
  port: 5433
