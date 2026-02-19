defmodule Elixirium.Mempool do
  use GenServer

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add_transaction(tx) do
    GenServer.cast(__MODULE__, {:add_transaction, tx})
  end

  def get_transactions() do
    GenServer.call(__MODULE__, :get_transactions)
  end

  def clear_transactions() do
    GenServer.cast(__MODULE__, :clear_transactions)
  end

  # Server Callbacks
  def init(_initial_state) do
    {:ok, %{transactions: []}}
  end

  def handle_call(:get_transactions, _from, state) do
    {:reply, state.transactions, state}
  end

  def handle_cast({:add_transaction, tx}, state) do
    {:noreply, update_in(state.transactions, &[tx | &1])}
  end

  def handle_cast(:clear_transactions, state) do
    {:noreply, %{state | transactions: []}}
  end
end
