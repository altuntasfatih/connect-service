defmodule ConnectService.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import ConnectService.DataCase

      use Oban.Testing, repo: ConnectService.Repo

      alias ConnectService.Repo
      alias ConnectService.Transfer
    end
  end

  setup tags do
    Ecto.Adapters.SQL.Sandbox.checkout(ConnectService.Repo)
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(ConnectService.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    :ok
  end

  def create_transfer(args) do
    ConnectService.Transfer.changeset(%ConnectService.Transfer{}, args)
    |> ConnectService.Repo.insert()
    |> then(fn {:ok, t} -> t end)
  end
end
