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

  def start_midi_server(name, conn) do
    registry_name = {:via, Registry, {MidiBot.Registry, name, %{}}}

    DynamicSupervisor.start_child(
      MidiBot.MidiSupervisor,
      {MidiBot.MidiServer, [name: registry_name, conn: conn]}
    )
  end

  def stop do
    DynamicSupervisor.stop(MidiBot.Supervisor)
  end

  def count_children do
    DynamicSupervisor.count_children(MidiBot.MidiSupervisor)
  end

  def start_midi_servers(n, conn) do
    Enum.each(1..n, fn _ ->
      name = "midi_server#{:crypto.strong_rand_bytes(10) |> Base.encode16()}"
      start_midi_server(name, conn)
    end)
  end

  def send_note(server_name) do
    GenServer.cast({:via, Registry, {MidiBot.Registry, server_name}}, :send_midi)
    :ok
  end
end
