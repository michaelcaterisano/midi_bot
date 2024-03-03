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

  def start_midi_server(name \\ nil) do
    name = name || "MidiBot#{:crypto.strong_rand_bytes(10) |> Base.encode16()}"
    registry_name = {:via, Registry, {MidiBot.Registry, name, %{}}}

    DynamicSupervisor.start_child(
      MidiBot.MidiSupervisor,
      {MidiBot.MidiServer, [name: registry_name, reference_name: name]}
    )
  end

  def start_midi_servers(n) do
    Enum.each(1..n, fn _ -> start_midi_server() end)
  end

  def send_note(server_name) do
    GenServer.call({:via, Registry, {MidiBot.Registry, server_name}}, :send_midi)
    :ok
  end
end
