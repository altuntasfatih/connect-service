defmodule ConnectService.Clients.GameClient do
  def call_handle_approved(%Contract.Transfer{}), do: :ok
  def call_handle_rejected(%Contract.Transfer{}), do: :ok
  def call_handle_expired(%Contract.Transfer{}), do: :ok
end
