defmodule KubaEngine.SystemMessage do
  alias __MODULE__

  defstruct [:body, :datetime]

  def new(body) do
    %SystemMessage{body: body, datetime: now()}
  end

  def new(body, datetime) do
    %SystemMessage{body: body, datetime: datetime}
  end

  def join(nick) do
    new("#{nick} joined")
  end

  def leave(nick) do
    new("#{nick} left")
  end

  def now do
    { :ok, now } = DateTime.now("Etc/UTC")
    now
  end
end
