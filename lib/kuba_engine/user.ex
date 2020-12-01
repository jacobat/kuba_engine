defmodule KubaEngine.User do
  alias __MODULE__

  defstruct [:nick, :ref]

  def new(nick) do
    %User{nick: nick, ref: make_ref}
  end
end
