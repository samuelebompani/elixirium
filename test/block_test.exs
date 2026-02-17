defmodule Elixirium.BlockTest do
  use ExUnit.Case
  doctest Elixirium.Block

  alias Elixirium.Block

  test "valid successor passes validation" do
    genesis = %Block{
      index: 0,
      timestamp: 1,
      transactions: [],
      previous_hash: "0",
      nonce: 0,
      hash: ""
    }

    genesis = %{genesis | hash: Block.hash_block(genesis)}

    mined =
      %Block{
        index: 1,
        timestamp: 2,
        transactions: [],
        previous_hash: genesis.hash,
        nonce: 0,
        hash: ""
      }
      |> Elixirium.Miner.mine()

    assert Block.valid_successor?(genesis, mined)
  end

  test "hashes is deterministic" do
    block = %Block{
      index: 1,
      timestamp: "2024-06-01T12:00:00Z",
      transactions: [],
      previous_hash: "0",
      nonce: 12345,
      hash: ""
    }

    hash1 = Block.hash_block(block)
    hash2 = Block.hash_block(block)
    assert hash1 == hash2
  end

  test "hash changes with nonce" do
    block = %Block{
      index: 1,
      timestamp: "2024-06-01T12:00:00Z",
      transactions: [],
      previous_hash: "0",
      nonce: 0,
      hash: ""
    }

    hash1 = Block.hash_block(block)
    updated_block = %{block | nonce: 1}
    hash2 = Block.hash_block(updated_block)
    assert hash1 != hash2
  end

  test "hash changes with transactions" do
    block = %Block{
      index: 1,
      timestamp: "2024-06-01T12:00:00Z",
      transactions: [],
      previous_hash: "0",
      nonce: 0,
      hash: ""
    }

    hash1 = Block.hash_block(block)
    updated_block = %{block | transactions: [%{from: "Alice", to: "Bob", amount: 10}]}
    hash2 = Block.hash_block(updated_block)
    assert hash1 != hash2
  end

  test "hash changes with previous hash" do
    block = %Block{
      index: 1,
      timestamp: "2024-06-01T12:00:00Z",
      transactions: [],
      previous_hash: "0",
      nonce: 0,
      hash: ""
    }

    hash1 = Block.hash_block(block)
    updated_block = %{block | previous_hash: "abc123"}
    hash2 = Block.hash_block(updated_block)
    assert hash1 != hash2
  end

  test "mining produces a valid hash" do
    block = %Block{
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

  test "mining changes the nonce" do
    block = %Block{
      index: 1,
      timestamp: "2024-06-01T12:00:00Z",
      transactions: [],
      previous_hash: "0",
      nonce: 0,
      hash: ""
    }

    mined_block = Elixirium.Miner.mine(block)
    assert mined_block.nonce != block.nonce
  end
end
