defmodule Elixirium.BlockTest do
  use ExUnit.Case
  doctest Elixirium.Block

  test "hashes is deterministic" do
    block = %Elixirium.Block{
      index: 1,
      timestamp: "2024-06-01T12:00:00Z",
      transactions: [],
      previous_hash: "0",
      nonce: 12345,
      hash: ""
    }
    hash1 = Elixirium.Block.hash_block(block)
    hash2 = Elixirium.Block.hash_block(block)
    assert hash1 == hash2
  end

  test "mining produces a valid hash" do
    block = %Elixirium.Block{
      index: 1,
      timestamp: "2024-06-01T12:00:00Z",
      transactions: [],
      previous_hash: "0",
      nonce: 0,
      hash: ""
    }
    mined_block = Elixirium.Miner.mine(block)
    assert String.starts_with?(mined_block.hash, "0000")
  end
end
