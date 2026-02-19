defmodule Elixirium.MempoolTest do
  use ExUnit.Case, async: false

  alias Elixirium.Mempool

  setup do
    Mempool.clear_transactions()
    :ok
  end

  test "starts empty" do
    assert Mempool.get_transactions() == []
  end

  test "add and retrieve transactions" do
    Mempool.add_transaction("tx1")
    Mempool.add_transaction("tx2")

    txs = Mempool.get_transactions()

    assert txs == ["tx1", "tx2"] || txs == ["tx2", "tx1"]
  end

  test "clear_transactions empties the pool" do
    Mempool.add_transaction("tx1")
    Mempool.add_transaction("tx2")

    Mempool.clear_transactions()

    assert Mempool.get_transactions() == []
  end

  test "can handle duplicate transactions (if allowed)" do
    Mempool.add_transaction("tx1")
    Mempool.add_transaction("tx1")

    txs = Mempool.get_transactions()

    assert txs == ["tx1", "tx1"]
  end

  test "concurrent transaction insertion works" do
    tasks =
      for i <- 1..20 do
        Task.async(fn ->
          Mempool.add_transaction("tx#{i}")
        end)
      end

    Enum.each(tasks, &Task.await/1)

    txs = Mempool.get_transactions()

    assert length(txs) == 20
    for i <- 1..20 do
      assert "tx#{i}" in txs
    end
  end
end
