defmodule Cache.Memory do
  use GenServer

  def new do
    {:ok, pid} = start_link
    {__MODULE__, pid}
  end

  def get(pid, key), do: GenServer.call(pid, {:get, key})
  def set(pid, key, value), do: GenServer.call(pid, {:set, key, value})

  def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, [], opts)

  def handle_call({:get, key}, _from, state) do
    result = if Map.has_key?(state, key) do
      {:found, state[key]}
    else
      :not_found
    end

    {:reply, result, state}
  end

  def handle_call({:set, key, value}, _from, state) do
    new_state = Map.put(state, key, value)

    {:reply, :ok, new_state}
  end

  def init(_args), do: {:ok, %{}}
end
