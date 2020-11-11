defmodule KubaEngine.Message do
  alias __MODULE__

  defstruct [:body, :author, :datetime]

  def new(body, author) do
    { :ok, %Message{body: body, author: author, datetime: now() } }
  end

  def new(body, author, datetime) do
    { :ok, %Message{body: body, author: author, datetime: datetime} }
  end

  def now do
    { :ok, now } = DateTime.now("Etc/UTC")
    now
  end
end
