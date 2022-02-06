defmodule KubaEngine.Channel do
  alias __MODULE__
  alias KubaEngine.SystemMessage

  defstruct [:name, :ref, :messages, :users]

  def new(name), do: %Channel{name: name, ref: make_ref(), messages: [], users: MapSet.new()}

  def member?(channel, user) do
    MapSet.member?(channel.users, user)
  end

  def join(channel, user) do
    if MapSet.member?(channel.users, user) do
      channel
    else
      new_users = MapSet.put(channel.users, user)
      %{channel | messages: [join_message(user.nick) | channel.messages], users: new_users}
    end
  end

  def leave(channel, user) do
    new_users = MapSet.delete(channel.users, user)
    %{channel | messages: [leave_message(user.nick) | channel.messages], users: new_users}
  end

  def speak(channel, message) do
    %{channel | messages: [message | channel.messages]}
  end

  defp join_message(nick) do
    SystemMessage.join(nick)
  end

  defp leave_message(nick) do
    SystemMessage.leave(nick)
  end
end
