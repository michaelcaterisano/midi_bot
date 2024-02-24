defmodule MidiBot do
  use Application

  def start(_type, _arg) do
    IO.inspect("starting")
    MidiBot.MidiSupervisor.start_link([])
  end
end
