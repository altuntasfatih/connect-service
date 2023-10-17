defmodule Worker.HandleTransferWorkerTest do
  use ConnectService.DataCase

  alias ConnectService.Worker.HandleTransferWorker

  test "it should finish successfully when client return ok" do
    %{id: id} = create_transfer(%{amount: 5.0})

    Oban.Testing.with_testing_mode(:inline, fn ->
      assert {:ok, %{state: "completed"}} = Oban.insert(HandleTransferWorker.new(%{id: id}))
    end)
  end

  test "it should retry job when client return error" do
    %{id: id} = create_transfer(%{amount: -1.0})

    Oban.Testing.with_testing_mode(:inline, fn ->
      {:ok, %{state: "retryable", errors: [_], attempt: 1}} =
        assert Oban.insert(HandleTransferWorker.new(%{id: id}))
    end)
  end
end
