defmodule KubaEngine.Channel do
  use GenServer

  alias __MODULE__

  defstruct [:name, :ref, :messages, :users]

  def start_link(name) when is_binary(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def init(name) do
    state_data =
      case :ets.lookup(:channel_state, name) do
        [] -> fresh_state(name)
        [{_key, state}] -> state
      end

    IO.puts "Initializing channel"
    :ets.insert(:channel_state, {name, state_data})
    {:ok, state_data }
  end

  def exist?(name), do: !Enum.empty?(Registry.lookup(Registry.Channel, name))

  defp fresh_state(name), do:
    %Channel{name: name, ref: make_ref(), messages: [], users: MapSet.new}

  def via_tuple(name), do: {:via, Registry, {Registry.Channel, name}}

  def name(pid), do: GenServer.call(pid, :name)

  def new(name) do
    init(name)
  end

  def join(name, user) do
    GenServer.call(via_tuple(name), {:join, user})
  end

  def leave(name, user) do
    GenServer.call(via_tuple(name), {:leave, user})
  end

  def channel_for(name) do
    GenServer.call(via_tuple(name), :channel)
  end

  def messages_for(name) do
    GenServer.call(via_tuple(name), :messages)
  end

  def speak(channel_name, {:ok, message}) do
    GenServer.cast(via_tuple(channel_name), {:speak, message})
  end

  def handle_info(:first, state) do
    IO.puts "Handled by first"
    {:noreply, state}
  end

  def handle_call(:channel, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:join, user}, _from, state) do
    if MapSet.member?(state.users, user) do
      {:reply, state, state}
    else
      new_users = MapSet.put(state.users, user)
      {:reply, state, %{ state | messages: [join_message(user.nick) | state.messages], users: new_users }}
    end
  end

  def handle_call({:leave, user}, _from, state) do
    new_users = MapSet.delete(state.users, user)
    {:reply, state, %{ state | messages: [leave_message(user.nick) | state.messages], users: new_users}}
  end

  def handle_call(:messages, _from, state) do
    {:reply, state.messages, state}
  end

  def handle_call(:name, _from, state) do
    {:reply, state.name, state}
  end

  def handle_cast({:speak, message}, state) do
    noreply_success(%{ state | messages: [message|state.messages] })
  end

  defp noreply_success(state_data) do
    :ets.insert(:channel_state, {state_data.name, state_data})
    {:noreply, state_data}
  end

  defp join_message(nick) do
    KubaEngine.SystemMessage.join(nick)
  end

  defp leave_message(nick) do
    KubaEngine.SystemMessage.leave(nick)
  end
end
