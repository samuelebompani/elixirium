defmodule Elixirium.Block do
  @enforce_keys [:index, :timestamp, :transactions, :previous_hash, :nonce, :hash]
  defstruct [:index, :timestamp, :transactions, :previous_hash, :nonce, :hash]

  def hash_block(block) do
    data =
      "#{block.index}#{block.timestamp}#{inspect(block.transactions)}#{block.previous_hash}#{block.nonce}"

    :crypto.hash(:sha256, data)
    |> Base.encode16(case: :lower)
  end
end
