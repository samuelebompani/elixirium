defmodule Elixirium.Block do
  @enforce_keys [:index, :timestamp, :transactions, :previous_hash, :nonce, :hash]
  defstruct [:index, :timestamp, :transactions, :previous_hash, :nonce, :hash]

  def valid_hash?(block) do
    computed = hash_block(block)
    computed == block.hash and String.starts_with?(computed, "0000")
  end

  def valid_successor?(previous, block) do
    previous.index + 1 == block.index and
      previous.hash == block.previous_hash and
      valid_hash?(block)
  end

  def hash_block(block) do
    data =
      "#{block.index}#{block.timestamp}#{inspect(block.transactions)}#{block.previous_hash}#{block.nonce}"

    :crypto.hash(:sha256, data)
    |> Base.encode16(case: :lower)
  end
end
