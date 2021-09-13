defmodule KubaEngine.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: KubaEngine.Worker.start_link(arg)
      # {KubaEngine.Worker, arg}
      {Registry, keys: :unique, name: Registry.Channel},
      {Phoenix.PubSub, name: :my_pubsub},
      KubaEngine.ChannelSupervisor
    ]

    :ets.new(:channel_state, [:public, :named_table])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KubaEngine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
