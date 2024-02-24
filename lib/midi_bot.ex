defmodule MidiBot do
  use Application

  def start(_type \\ nil, _arg \\ nil) do
    IO.inspect("starting")
    MidiBot.MidiSupervisor.start_link([])
  end
end
