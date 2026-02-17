defmodule Elixirium.Miner do
  alias Elixirium.Block

  @difficulty "0000"

  def mine(block) do
    do_mine(block, 0)
  end

  defp do_mine(block, nonce) do
    updated = %{block | nonce: nonce}
    hash = Block.hash_block(updated)

    if(String.starts_with?(hash, @difficulty)) do
      %{updated | hash: hash}
    else
      do_mine(block, nonce + 1)
    end
  end
end
