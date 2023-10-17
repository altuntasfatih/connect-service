defmodule ConnectService.Worker.HandleExpiredWorker do
  use Oban.Worker,
    queue: :handler,
    max_attempts: 5

  alias ConnectService.Clients.GameClient
  alias ConnectService.Clients.WalletClient
  alias ConnectService.Repo
  alias ConnectService.Transfer

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    t = Repo.get!(Transfer, id)

    transfer = %Contract.Transfer{
      id: t.id,
      uuid: t.uuid,
      status: t.status,
      amount: t.amount,
      expires_at: t.expires_at
    }

    with :ok <- GameClient.call_handle_expired(transfer),
         :ok <- WalletClient.call_handle_expired(transfer) do
      :ok
    end
  end
end
