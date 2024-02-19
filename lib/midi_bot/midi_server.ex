defmodule MidiBot.MidiServer do
  @name :midi_server

  use GenServer

  def start do
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  @impl true
  def init(_state) do
    [port] = Midiex.ports("IAC Driver Bus 1", :output)
    out_conn = Midiex.open(port)
    state = %{out_conn: out_conn, note: note()}
    Process.send_after(self(), :send_midi, Enum.random(20..1000))
    {:ok, state}
  end

  @impl true
  def handle_info(:send_midi, state) do
    Task.start(fn -> send_note(state) end)

    new_note = note()
    state = %{state | note: new_note}
    Process.send_after(self(), :send_midi, Enum.random(20..1000))
    {:noreply, state}
  end

  # Client functions

  @spec note() :: {Midiex.Message.t(), Midiex.Message.t(), integer}
  defp note do
    note_on = Midiex.Message.note_on(Enum.random(40..80), Enum.random(40..80), channel: 1)
    <<_, note, _>> = note_on
    note_off = Midiex.Message.note_off(note, 127, channel: 1)
    duration = 2000
    {note_on, note_off, duration}
  end

  defp send_note(state) do
    {note_on, note_off, duration} = state.note
    Midiex.send_msg(state.out_conn, note_on)
    :timer.sleep(duration)
    Midiex.send_msg(state.out_conn, note_off)
  end
end

server = MidiBot.MidiServer.start()
