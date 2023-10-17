defmodule ConnectService.Worker.HandleTransferWorkerTest do
  use ConnectService.DataCase

  alias ConnectService.Worker.ExpireWorker

  describe "perform_job/1" do
    test "it should expire transfers" do
      # given
      transfer =
        for i <- 1..5,
            do:
              create_transfer(%{
                status: :OPEN,
                amount: i * 20,
                expires_at: DateTime.add(DateTime.utc_now(), -i * 60, :second)
              })

      # when&then
      assert :ok = perform_job(ExpireWorker, %{})

      Enum.each(transfer, fn transfer ->
        assert %Transfer{
                 status: :EXPIRED
               } = Repo.one!(from(t in Transfer, where: t.id == ^transfer.id))
      end)
    end
  end
end
