import Config

config :connect_service, :ecto_repos, [ConnectService.Repo]

config :logger, :console, format: "$time $metadata[$level] $message\n"

config :connect_service, Oban,
  repo: ConnectService.Repo,
  plugins: [
    {Oban.Plugins.Pruner, max_age: 3000},
    {Oban.Plugins.Cron,
     crontab: [
       {"* * * * *", ConnectService.Worker.ExpireWorker, queue: :expire_worker}
     ]}
  ],
  queues: [default: 10, handler: 20, expire_worker: 1]

config :grpc, start_server: true

import_config "#{Mix.env()}.exs"
