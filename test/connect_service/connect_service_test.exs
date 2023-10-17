defmodule ConnectServiceTest do
  use ConnectService.DataCase

  alias ConnectService.Worker.HandleApprovedWorker
  alias ConnectService.Worker.HandleExpiredWorker
  alias ConnectService.Worker.HandleRejectedWorker
  alias ConnectService.Worker.HandleTransferWorker
  alias Contract.ApproveRequest
  alias Contract.InitMoneyTransferRequest
  alias Contract.RejectRequest

  test "it should create money transfer and insert HandleTransferWorker job" do
    amount = 5.1

    assert {:ok, %{id: id, amount: ^amount, status: :OPEN}} =
             ConnectService.init_money_transfer(%InitMoneyTransferRequest{amount: amount})

    assert_enqueued(worker: HandleTransferWorker, args: %{id: id})
  end

  test "it should approve money transfer and insert HandleApprovedWorker job" do
    transfer = create_transfer(%{amount: 9.0, status: :OPEN})

    assert {:ok, %{status: :APPROVED}} =
             ConnectService.approve_money_transfer(%ApproveRequest{uuid: transfer.uuid})

    assert_enqueued(worker: HandleApprovedWorker, args: %{id: transfer.id})
  end

  test "it should return invalid state error and not insert HandleApprovedWorker job" do
    transfer = create_transfer(%{amount: 9.0, status: :REJECTED})

    assert {:error, :invalid_state} =
             ConnectService.approve_money_transfer(%ApproveRequest{uuid: transfer.uuid})

    refute_enqueued(worker: HandleApprovedWorker, args: %{id: transfer.id})
  end

  test "it should reject money transfer and insert HandleRejectedWorker job" do
    transfer = create_transfer(%{amount: 9.0, status: :OPEN})

    assert {:ok, %{status: :REJECTED}} =
             ConnectService.reject_money_transfer(%RejectRequest{uuid: transfer.uuid})

    assert_enqueued(worker: HandleRejectedWorker, args: %{id: transfer.id})
  end

  test "it should expire money transfer" do
    transfer =
      create_transfer(%{
        amount: 9.0,
        status: :OPEN,
        expires_at: DateTime.add(DateTime.utc_now(), -10 * 60, :second)
      })

    assert {:ok, %{status: :EXPIRED}} =
             ConnectService.expire(transfer.uuid)

    assert_enqueued(worker: HandleExpiredWorker, args: %{id: transfer.id})
  end

  test "it should return not expired error" do
    transfer =
      create_transfer(%{
        amount: 9.0,
        status: :OPEN,
        expires_at: DateTime.add(DateTime.utc_now(), 10 * 60, :second)
      })

    assert {:error, :not_expired} =
             ConnectService.expire(transfer.uuid)

    refute_enqueued(worker: HandleExpiredWorker, args: %{id: transfer.id})
  end
end
