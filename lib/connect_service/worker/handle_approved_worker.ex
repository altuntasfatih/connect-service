defmodule ConnectService.Worker.HandleApprovedWorker do
  use Oban.Worker,
    queue: :handler,
    max_attempts: 5

  alias ConnectService.Clients.GameClient
  alias ConnectService.Repo
  alias ConnectService.Transfer

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    transfer = Repo.get!(Transfer, id)

    GameClient.call_handle_approved(%Contract.Transfer{
      id: transfer.id,
      uuid: transfer.uuid,
      status: transfer.status,
      amount: transfer.amount,
      expires_at: transfer.expires_at
    })
  end
end
