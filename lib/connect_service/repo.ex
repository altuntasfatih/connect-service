defmodule ConnectService.Repo do
  use Ecto.Repo,
    otp_app: :connect_service,
    adapter: Ecto.Adapters.Postgres
end
