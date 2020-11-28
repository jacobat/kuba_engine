defmodule KubaEngine.ChannelSupervisor do
  use DynamicSupervisor

  alias KubaEngine.Channel

  def start_link(_options) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_channel(name) do
    spec = {Channel, name}
    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, _pid} -> {}
      {:error, {:already_started, _pid}} -> {}
      error -> raise error
    end
  end

  def stop_channel(name), do: DynamicSupervisor.terminate_child(__MODULE__, pid_from_name(name))

  defp pid_from_name(name) do
    name
    |> Channel.via_tuple()
    |> GenServer.whereis()
  end
end
