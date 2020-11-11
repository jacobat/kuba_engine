defmodule KubaEngineTest do
  use ExUnit.Case
  doctest KubaEngine

  test "greets the world" do
    assert KubaEngine.hello() == :world
  end
end
