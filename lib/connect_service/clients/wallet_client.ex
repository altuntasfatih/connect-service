defmodule ConnectService.Clients.WalletClient do
  def call_handle_transfer(%Contract.Transfer{amount: amount}) when amount > 0, do: :ok
  def call_handle_transfer(_), do: {:error, :timeout}
  def call_handle_expired(%Contract.Transfer{}), do: :ok
end
