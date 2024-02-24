defmodule MidiBot do
  use Application

  def start(_type, _arg) do
    IO.inspect("starting midibot application")
    MidiBot.Supervisor.start_link()
  end
end
