defmodule Elixirium.ChainTest do
  use ExUnit.Case
  doctest Elixirium.Chain

  alias Elixirium.Chain

  setup do
    {:ok, pid} = Chain.start_link([])
    %{pid: pid}
  end

  test "genesis block exists", %{pid: pid} do
    chain = Chain.get_chain(pid)
    assert length(chain) == 1
  end

  test "can add a block", %{pid: pid} do
    Chain.request_mine(pid, ["tx1"])

    assert_receive {:block_added, block}, 5_000

    assert block.index == 1
    chain = Chain.get_chain(pid)
    assert List.last(chain).transactions == ["tx1"]
  end

  test "chain is valid after adding blocks", %{pid: pid} do
    Chain.request_mine(pid, ["tx1"])
    assert_receive {:block_added, _}, 5_000

    Chain.request_mine(pid, ["tx2"])
    assert_receive {:block_added, _}, 5_000


    assert Chain.valid_chain?(pid)
  end

  test "tampered block invalidates chain", %{pid: pid} do
    Chain.request_mine(pid, ["tx1"])
    assert_receive {:block_added, _}, 5_000

    chain = Chain.get_chain(pid)

    tampered =
      chain
      |> List.update_at(1, fn block ->
        %{block | transactions: ["evil_tx"]}
      end)

    refute Elixirium.Block.valid_chain?(tampered)
  end
end
