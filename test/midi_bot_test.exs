defmodule MidiBotTest do
  use ExUnit.Case
  doctest MidiBot

  test "greets the world" do
    assert MidiBot.hello() == :world
  end
end
