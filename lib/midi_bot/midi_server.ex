defmodule MidiBot.MidiServer do
  @name :midi_server
  @send_interval :timer.seconds(1)

  use GenServer

  def start do
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  def init(_state) do
    [port] = Midiex.ports("IAC Driver Bus 1", :output)
    out_conn = Midiex.open(port)
    state = %{out_conn: out_conn, note: note()}
    IO.inspect(state, label: "state")
    Process.send_after(self(), :send_midi, @send_interval)
    {:ok, state}
  end

  def handle_info(:send_midi, state) do
    send_note(state)
    new_note = note()
    state = %{state | note: new_note}
    Process.send_after(self(), :send_midi, @send_interval)
    {:noreply, state}
  end

  @doc """
    Returns a three tuple with a note_on message, a note_off message and a duration
  """
  @spec note() :: {Midiex.Message.t(), Midiex.Message.t(), integer}
  defp note do
    note_on = Midiex.Message.note_on(Enum.random(40..80), Enum.random(40..80), channel: 1)
    <<_, note, _>> = note_on
    note_off = Midiex.Message.note_off(note, 127, channel: 1)
    duration = Enum.random(100..1000)
    {note_on, note_off, duration}
  end

  defp send_note(state) do
    {note_on, note_off, duration} = state.note
    Midiex.send_msg(state.out_conn, note_on)
    :timer.sleep(duration)
    Midiex.send_msg(state.out_conn, note_off)
  end
end
