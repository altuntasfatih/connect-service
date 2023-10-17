defmodule ConnectService.Worker.HandleTransferWorker do
  use Oban.Worker,
    queue: :handler,
    max_attempts: 5

  alias ConnectService.Transfer
  alias ConnectService.Repo
  alias ConnectService.Clients.WalletClient

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    transfer = Repo.get!(Transfer, id)

    WalletClient.call_handle_transfer(%Contract.Transfer{
      id: transfer.id,
      uuid: transfer.uuid,
      status: transfer.status,
      amount: transfer.amount,
      expires_at: transfer.expires_at
    })
  end
end
