defmodule KubaEngine.ChannelServer do
  use GenServer

  alias __MODULE__
  alias KubaEngine.Channel

  defstruct [:name, :ref, :messages, :users]

  def start_link(name) when is_binary(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def init(name) do
    channel =
      case :ets.lookup(:channel_state, name) do
        [] -> Channel.new(name)
        [{_key, channel}] -> channel
      end

    IO.puts("Initializing channel")
    :ets.insert(:channel_state, {name, channel})
    {:ok, channel}
  end

  def exist?(name), do: !Enum.empty?(Registry.lookup(Registry.ChannelServer, name))

  def via_tuple(name), do: {:via, Registry, {Registry.ChannelServer, name}}

  def name(pid), do: GenServer.call(pid, :name)

  def new(name) do
    init(name)
  end

  def member?(name, user) do
    GenServer.call(via_tuple(name), {:member?, user})
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

  def speak(channel_name, message) do
    GenServer.cast(via_tuple(channel_name), {:speak, message})
  end

  def handle_info(:first, channel) do
    IO.puts("Handled by first")
    {:noreply, channel}
  end

  def handle_call(:channel, _from, channel) do
    {:reply, channel, channel}
  end

  def handle_call({:member?, user}, _from, channel) do
    {:reply, Channel.member?(channel, user), channel}
  end

  def handle_call({:join, user}, _from, channel) do
    if Channel.member?(channel, user) do
      {:reply, channel, channel}
    else
      {:reply, channel, Channel.join(channel, user)}
    end
  end

  def handle_call({:leave, user}, _from, channel) do
    {:reply, channel, Channel.leave(channel, user)}
  end

  def handle_call(:messages, _from, channel) do
    {:reply, channel.messages, channel}
  end

  def handle_call(:name, _from, channel) do
    {:reply, channel.name, channel}
  end

  def handle_cast({:speak, message}, channel) do
    noreply_success(Channel.speak(channel, message))
  end

  defp noreply_success(channel) do
    :ets.insert(:channel_state, {channel.name, channel})
    {:noreply, channel}
  end
end
