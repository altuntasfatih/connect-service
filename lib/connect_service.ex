defmodule ConnectService do
  import Ecto.Query

  alias ConnectService.Repo
  alias ConnectService.Transfer
  alias ConnectService.Worker.HandleApprovedWorker
  alias ConnectService.Worker.HandleExpiredWorker
  alias ConnectService.Worker.HandleRejectedWorker
  alias ConnectService.Worker.HandleTransferWorker

  def init_money_transfer(%Contract.InitMoneyTransferRequest{amount: amount}) do
    Repo.transaction(fn _ ->
      with {:ok, %Transfer{} = t} <-
             Repo.insert(Transfer.changeset(%Transfer{}, %{amount: amount})),
           {:ok, _} <- Oban.insert(HandleTransferWorker.new(%{id: t.id})) do
        %Contract.Transfer{
          id: t.id,
          uuid: t.uuid,
          status: t.status,
          amount: t.amount,
          expires_at: DateTime.to_string(t.expires_at)
        }
      end
    end)
  end

  def approve_money_transfer(%Contract.ApproveRequest{uuid: uuid}) do
    Repo.transaction(fn _ ->
      with %Transfer{status: :OPEN} = t <-
             Repo.one(from(t in Transfer, where: t.uuid == ^uuid)),
           {:ok, t} <- Repo.update(Transfer.changeset(t, %{status: :APPROVED})),
           {:ok, _} <- Oban.insert(HandleApprovedWorker.new(%{id: t.id})) do
        %Contract.Transfer{
          id: t.id,
          uuid: t.uuid,
          status: t.status,
          amount: t.amount,
          expires_at: DateTime.to_string(t.expires_at)
        }
      else
        %Transfer{} -> Repo.rollback(:invalid_state)
      end
    end)
  end

  def reject_money_transfer(%Contract.RejectRequest{uuid: uuid}) do
    Repo.transaction(fn _ ->
      with %Transfer{status: :OPEN} = t <-
             Repo.one(from(t in Transfer, where: t.uuid == ^uuid)),
           {:ok, transfer} <- Repo.update(Transfer.changeset(t, %{status: :REJECTED})),
           {:ok, _} <- Oban.insert(HandleRejectedWorker.new(%{id: transfer.id})) do
        %Contract.Transfer{
          id: transfer.id,
          uuid: transfer.uuid,
          status: transfer.status,
          amount: transfer.amount,
          expires_at: DateTime.to_string(transfer.expires_at)
        }
      end
    end)
  end

  def expire(uuid) do
    Repo.transaction(fn _ ->
      with %Transfer{status: :OPEN, expires_at: expires_at} = t <-
             Repo.one(from(t in Transfer, where: t.uuid == ^uuid)),
           false <- expired?(expires_at),
           {:ok, transfer} <- Repo.update(Transfer.changeset(t, %{status: :EXPIRED})),
           {:ok, _} <- Oban.insert(HandleExpiredWorker.new(%{id: transfer.id})) do
        %Contract.Transfer{
          id: transfer.id,
          uuid: transfer.uuid,
          status: transfer.status,
          amount: transfer.amount,
          expires_at: DateTime.to_string(transfer.expires_at)
        }
      else
        err -> Repo.rollback(err)
      end
    end)
  end

  defp expired?(expires_at) do
    with true <- DateTime.compare(expires_at, DateTime.utc_now()) == :gt,
         do: :not_expired
  end
end
