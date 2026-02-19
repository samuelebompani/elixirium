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

  def request_mine(pid) do
    GenServer.cast(pid, {:mine, self()})
  end

  def valid_chain?(pid) do
    GenServer.call(pid, :valid_chain)
  end

  ## Server Callbacks

  @impl true
  def init(:ok) do
    genesis_block = create_genesis_block()
    {:ok, %{chain: [genesis_block], mining: false}}
  end

  @impl true
  def handle_call(:get_chain, _from, state) do
    {:reply, state.chain, state}
  end

  @impl true
  def handle_call(:valid_chain, _from, state) do
    {:reply, Block.valid_chain?(state.chain), state}
  end

  @impl true
  def handle_cast({:mine, _caller}, %{mining: true} = state) do
    {:noreply, state}
  end

  def handle_cast({:mine, caller}, %{mining: false} = state) do
    transactions = Elixirium.Mempool.get_transactions()

    if transactions == [] do
      {:noreply, state}
    else
      last_block = List.last(state.chain)

      candidate = %Block{
        index: last_block.index + 1,
        timestamp: System.system_time(:second),
        transactions: transactions,
        previous_hash: last_block.hash,
        nonce: 0,
        hash: ""
      }

      pid = self()

      Task.Supervisor.start_child(Elixirium.MiningSupervisor, fn ->
        mined = Miner.mine(candidate)
        send(pid, {:mined_block, mined, caller})
      end)

      {:noreply, %{state | mining: true}}
    end
  end

  @impl true
  def handle_info({:mined_block, block, caller}, state) do
    last_block = List.last(state.chain)

    if Block.valid_successor?(last_block, block) do
      send(caller, {:block_added, block})

      new_state = %{
        state
        | chain: state.chain ++ [block],
          mining: false
      }
      Elixirium.Mempool.clear_transactions()
      {:noreply, new_state}
    else
      {:noreply, %{state | mining: false}}
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

    Miner.mine(block)
  end
end
