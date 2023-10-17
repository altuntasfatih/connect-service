defmodule ConnectService.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [ConnectService.Repo, {Oban, Application.fetch_env!(:connect_service, Oban)}]

    opts = [strategy: :one_for_one, name: ConnectService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
