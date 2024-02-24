defmodule MidiBot.MidiSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init([]) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_midi_server(port_name, server_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {MidiBot.MidiServer, %{port_name: port_name, server_name: server_name}}
    )
  end
end
