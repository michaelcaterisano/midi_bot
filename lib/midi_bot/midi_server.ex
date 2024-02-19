defmodule MidiBot.MidiServer do
  @name :midi_server

  use GenServer

  alias MidiBot.Note

  def start do
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  @impl true
  def init(_state) do
    [port] = Midiex.ports("MRCC 880 Port 1", :output)
    IO.inspect(port)
    Process.send_after(self(), :send_midi, Enum.random(20..1000))
    {:ok, %{destination: Midiex.open(port), note: Note.new()}}
  end

  def set_destination(%{name: name, direction: direction} = destination) do
    GenServer.call(@name, {:set_destination, destination})
  end

  def set_destination(_) do
    raise "Invalid destination, must pass a map with :name and :direction keys"
  end

  def get_destination do
    GenServer.call(@name, :get_destination)
  end

  @impl true
  def handle_call(:get_destination, _from, state) do
    {:reply, state.destination, state}
  end

  def handle_call({:set_destination, destination}, _from, state) do
    [port] = Midiex.ports(destination.name, destination.direction)
    IO.inspect(port)
    Process.send_after(self(), :send_midi, Enum.random(20..1000))
    {:reply, destination, %{state | destination: Midiex.open(port)}}
  end

  @impl true
  def handle_info(:send_midi, state) do
    Task.start(fn -> send_note(state) end)
    Process.send_after(self(), :send_midi, Enum.random(20..1000))
    {:noreply, %{state | note: Note.new()}}
  end

  defp send_note(state) do
    %{note_on: note_on, note_off: note_off, duration: duration} = state.note
    Midiex.send_msg(state.destination, note_on)
    :timer.sleep(duration)
    Midiex.send_msg(state.destination, note_off)
  end
end

MidiBot.MidiServer.start()