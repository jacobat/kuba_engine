defmodule KubaEngine.SystemMessage do
  alias __MODULE__

  defstruct [:body, :datetime]

  def new(body) do
    { :ok, %SystemMessage{body: body, datetime: now() } }
  end

  def new(body, datetime) do
    { :ok, %SystemMessage{body: body, datetime: datetime} }
  end

  def now do
    { :ok, now } = DateTime.now("Etc/UTC")
    now
  end
end

