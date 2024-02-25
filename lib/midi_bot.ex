defmodule MidiBot do
  use Application

  require Logger

  def start(_type, _arg) do
    Logger.info("starting midibot application")

    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: MidiBot.MidiSupervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: MidiBot.Supervisor)
  end

  def start_midi_server(port_name) do
    DynamicSupervisor.start_child(
      MidiBot.MidiSupervisor,
      {MidiBot.MidiServer, %{port_name: port_name}}
    )
  end

  def start_midi_servers(n, port_name) do
    Enum.each(1..n, fn _ -> start_midi_server(port_name) end)
  end
end
