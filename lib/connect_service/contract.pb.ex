defmodule Contract.TransferStatus do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field(:OPEN, 0)
  field(:APPROVED, 1)
  field(:REJECTED, 2)
  field(:EXPIRED, 3)
end

defmodule Contract.Transfer do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field(:id, 1, type: :int64)
  field(:uuid, 2, type: :string)
  field(:amount, 3, type: :float)
  field(:status, 4, type: Contract.TransferStatus, enum: true)
  field(:expires_at, 5, type: :string, json_name: "expiresAt")
end

defmodule Contract.InitMoneyTransferRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field(:amount, 2, type: :float)
end

defmodule Contract.ApproveRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field(:uuid, 1, type: :string)
end

defmodule Contract.RejectRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field(:uuid, 1, type: :string)
end

defmodule Contract.Response do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"
end
