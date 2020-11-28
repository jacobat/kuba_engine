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
    %Channel{name: name, ref: make_ref(), messages: [], users: []}

  def via_tuple(name), do: {:via, Registry, {Registry.Channel, name}}

  def name(pid), do: GenServer.call(pid, :name)

  def new(name) do
    init(name)
  end

  def join(name, nick) do
    GenServer.call(via_tuple(name), {:join, nick})
  end

  def leave(name, nick) do
    GenServer.call(via_tuple(name), {:leave, nick})
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

  def handle_call({:join, nick}, _from, state) do
    {:reply, state, %{ state | messages: [join_message(nick) | state.messages], users: [nick | state.users]}}
  end

  def handle_call({:leave, nick}, _from, state) do
    {:reply, state, %{ state | messages: [leave_message(nick) | state.messages], users: List.delete(state.users, nick)}}
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
    {:ok, message} = KubaEngine.SystemMessage.new("#{nick} joined")
    message
  end

  defp leave_message(nick) do
    {:ok, message} = KubaEngine.SystemMessage.new("#{nick} left")
    message
  end
end
