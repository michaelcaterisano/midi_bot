defmodule MidiBot.MidiServer do
  use GenServer

  alias MidiBot.Note

  def start_link(args) do
    IO.inspect(args, label: "args")
    IO.inspect("starting midi server")

    GenServer.start_link(__MODULE__, %{port: args[:port], direction: args[:direction]},
      name: args[:name]
    )
  end

  @impl true
  def init(state) do
    port = Midiex.ports(state.port, state.direction) |> List.first()
    intial_note = Note.new()
    {:ok, %{port: Midiex.open(port), note: intial_note}}
  end

  def set_port(name, direction) do
    port = Midiex.ports(name, direction) |> List.first()
    GenServer.call(self(), {:set_port, port})
  end

  def get_port do
    GenServer.call(self(), :get_port)
  end

  def get_ports do
    Midiex.ports()
  end

  @impl true
  def handle_call(:get_port, _from, state) do
    {:reply, state.port, state}
  end

  def handle_call({:set_port, port}, _from, state) do
    {:reply, port, %{state | port: Midiex.open(port)}}
  end

  @impl true
  def handle_call(:send_midi, _from, state) do
    Task.start(fn -> send_note(state) end)
    new_state = %{state | note: Note.new()}
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_info(:send_midi, state) do
    Task.start(fn -> send_note(state) end)
    # Process.send_after(self(), :send_midi, Enum.random(20..1000))
    {:noreply, %{state | note: Note.new()}}
  end

  defp send_note(state) do
    %{note_on: note_on, note_off: note_off, duration: duration} = state.note
    Midiex.send_msg(state.port, note_on)
    :timer.sleep(duration)
    Midiex.send_msg(state.port, note_off)
  end
end
