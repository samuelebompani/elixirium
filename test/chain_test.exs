defmodule Elixirium.ChainTest do
  use ExUnit.Case, async: false

  alias Elixirium.{Chain, Mempool, Block}

  setup do
    {:ok, pid} = Chain.start_link([])
    %{pid: pid}
  end

  # ------------------
  # Helpers
  # ------------------

  defp add_tx(tx) do
    Mempool.add_transaction(tx)
  end

  defp mine_block(pid, timeout \\ 5_000) do
    Chain.request_mine(pid)
    assert_receive {:block_added, block}, timeout
    block
  end

  # ------------------
  # Tests
  # ------------------

  test "genesis block exists", %{pid: pid} do
    chain = Chain.get_chain(pid)
    assert length(chain) == 1
  end

  test "mining adds a block with mempool transactions", %{pid: pid} do
    add_tx("tx1")

    block = mine_block(pid)

    assert block.index == 1
    assert block.transactions == ["tx1"]

    chain = Chain.get_chain(pid)
    assert length(chain) == 2
  end

  test "chain remains valid after multiple blocks", %{pid: pid} do
    add_tx("tx1")
    mine_block(pid)

    add_tx("tx2")
    mine_block(pid)

    assert Chain.valid_chain?(pid)
  end

  test "tampering invalidates the chain", %{pid: pid} do
    add_tx("tx1")
    mine_block(pid)

    chain = Chain.get_chain(pid)

    tampered =
      List.update_at(chain, 1, fn block ->
        %{block | transactions: ["evil_tx"]}
      end)

    refute Block.valid_chain?(tampered)
  end

  test "mining consumes mempool transactions", %{pid: pid} do
    Mempool.add_transaction("tx1")
    Mempool.add_transaction("tx2")

    Elixirium.Chain.request_mine(pid)

    assert_receive {:block_added, block}, 5_000

    assert length(block.transactions) == 2
    assert Mempool.get_transactions() == []
  end
end
