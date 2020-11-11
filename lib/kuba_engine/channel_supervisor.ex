defmodule KubaEngine.ChannelSupervisor do
  use Supervisor

  alias KubaEngine.Channel

  def start_link(_options), do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  
  def init(:ok), do: Supervisor.init([Channel], strategy: :simple_one_for_one)

  def start_channel(name), do: Supervisor.start_child(__MODULE__, [name])

  def stop_channel(name), do: Supervisor.terminate_child(__MODULE__, pid_from_name(name))

  defp pid_from_name(name) do
    name
    |> Channel.via_tuple()
    |> GenServer.whereis()
  end
end
