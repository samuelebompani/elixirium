defmodule Elixirium.Chain do
  use GenServer

  alias Elixirium.{Block, Miner}

  ## Client API
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def get_chain(pid) do
    GenServer.call(pid, :get_chain)
  end

  def add_block(pid, transactions) do
    GenServer.call(pid, {:add_block, transactions})
  end

  ## Server Callbacks

  @impl true
  def init(:ok) do
    genesis_block = create_genesis_block()
    {:ok, [genesis_block]}
  end

  @impl true
  def handle_call(:get_chain, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:add_block, transactions}, _from, state) do
    last_block = List.last(state)

    candidate =
      %Block{
        index: last_block.index + 1,
        timestamp: System.system_time(:second),
        transactions: transactions,
        previous_hash: last_block.hash,
        nonce: 0,
        hash: ""
      }
      |> Miner.mine()

    if Block.valid_successor?(last_block, candidate) do
      {:reply, {:ok, candidate}, state ++ [candidate]}
    else
      {:reply, {:error, :invalid_block}, state}
    end
  end

  defp create_genesis_block do
    block = %Block{
      index: 0,
      timestamp: System.system_time(:second),
      transactions: [],
      previous_hash: "0",
      nonce: 0,
      hash: ""
    }

    %{block | hash: Block.hash_block(block)}
  end
end
