defmodule ConnectService.Worker.ExpireWorker do
  use Oban.Worker,
    queue: :expire_worker,
    max_attempts: 5

  import Ecto.Query

  alias ConnectService
  alias ConnectService.Repo
  alias ConnectService.Transfer

  @limit 5
  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    get_expired_connections()
    |> Enum.each(&ConnectService.expire(&1.uuid))

    :ok
  end

  defp get_expired_connections do
    limit = @limit
    now = DateTime.utc_now()

    from(t in Transfer,
      where: t.status == :OPEN and t.expires_at < ^now,
      limit: ^limit
    )
    |> Repo.all()
  end
end
