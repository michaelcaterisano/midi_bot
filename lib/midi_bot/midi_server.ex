defmodule MidiBot.MidiServer do
  @name :midi_server
  @note_duration 2000

  use GenServer

  def start do
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  @impl true
  def init(_state) do
    [port] = Midiex.ports("IAC Driver Bus 1", :output)
    Process.send_after(self(), :send_midi, Enum.random(20..1000))
    {:ok, %{destination: Midiex.open(port), note: note()}}
  end

  def set_midi_device(midi_device) do
    GenServer.call(@name, {:set_midi_device, midi_device})
  end

  def get_midi_device do
    GenServer.call(@name, :get_midi_device)
  end

  @impl true
  def handle_call(:get_midi_device, _from, state) do
    {:reply, state.destination, state}
  end

  def handle_call({:set_midi_device, midi_device}, _from, state) do
    [port] = Midiex.ports(midi_device, :output)
    Process.send_after(self(), :send_midi, Enum.random(20..1000))
    {:reply, midi_device, %{state | destination: Midiex.open(port)}}
  end

  @impl true
  def handle_info(:send_midi, state) do
    Task.start(fn -> send_note(state) end)
    Process.send_after(self(), :send_midi, Enum.random(20..1000))
    {:noreply, %{state | note: note()}}
  end

  @spec note() :: {Midiex.Message.t(), Midiex.Message.t(), integer}
  defp note do
    note_on = Midiex.Message.note_on(Enum.random(40..80), Enum.random(40..80), channel: 1)
    <<_, note, _>> = note_on
    note_off = Midiex.Message.note_off(note, 127, channel: 1)
    {note_on, note_off, @note_duration}
  end

  defp send_note(state) do
    {note_on, note_off, duration} = state.note
    Midiex.send_msg(state.destination, note_on)
    :timer.sleep(duration)
    Midiex.send_msg(state.destination, note_off)
  end
end
