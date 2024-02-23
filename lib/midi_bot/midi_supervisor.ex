defmodule MidiBot.Supervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [init_arg]
    )
  end

  def start_midi_server(args) do
    DynamicSupervisor.start_child(__MODULE__, {MidiBot.MidiServer, args})
  end
end
