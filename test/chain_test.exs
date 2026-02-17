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
    Chain.add_block(pid, ["tx1"])
    chain = Chain.get_chain(pid)

    assert length(chain) == 2
    assert List.last(chain).transactions == ["tx1"]
  end
end
