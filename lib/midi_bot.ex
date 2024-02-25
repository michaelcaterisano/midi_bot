defmodule MidiBot do
  use Application

  require Logger

  def start(_type, _arg) do
    Logger.info("starting midibot application")

    children = [
      {Registry, keys: :unique, name: MidiBot.Registry},
      {DynamicSupervisor, strategy: :one_for_one, name: MidiBot.MidiSupervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: MidiBot.Supervisor)
  end

  def start_midi_server({port, direction}, name) do
    name = {:via, Registry, {MidiBot.Registry, name, %{port: port, direction: direction}}}

    DynamicSupervisor.start_child(
      MidiBot.MidiSupervisor,
      {MidiBot.MidiServer, [name: name, port: port, direction: direction]}
    )
  end

  def start_midi_servers(n, {port, direction}, name) do
    Enum.each(1..n, fn _ -> start_midi_server({port, direction}, name) end)
  end

  def send_note(server_name) do
    GenServer.call({:via, Registry, {MidiBot.Registry, server_name}}, :send_midi)
  end
end
