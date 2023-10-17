defmodule ConnectService.Transfer do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Ecto.Changeset
  alias Ecto.UUID
  alias __MODULE__

  @expire_after_minute 5

  schema "transfers" do
    field(:uuid, UUID)
    field(:status, Ecto.Enum, values: [:OPEN, :APPROVED, :REJECTED, :EXPIRED], default: :OPEN)
    field(:amount, :float)
    field(:expires_at, :utc_datetime)

    timestamps()
  end

  @fields ~w(amount status expires_at)a
  def changeset(connection, attrs) do
    connection
    |> cast(attrs, @fields)
    |> set_expire_time()
    |> default_uuid()
  end

  defp default_uuid(%Changeset{data: %Transfer{uuid: nil}} = c),
    do: put_change(c, :uuid, UUID.generate())

  defp default_uuid(%Changeset{} = c), do: c

  defp set_expire_time(%Changeset{changes: %{expires_at: _}} = c), do: c

  defp set_expire_time(%Changeset{data: %Transfer{expires_at: nil}} = c) do
    expires_at =
      DateTime.add(DateTime.utc_now(), @expire_after_minute * 60, :second)
      |> DateTime.truncate(:second)

    put_change(c, :expires_at, expires_at)
  end

  defp set_expire_time(%Changeset{} = c), do: c
end
