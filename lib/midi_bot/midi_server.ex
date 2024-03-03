defmodule MidiBot.MidiServer do
  use GenServer

  alias MidiBot.Note

  def start_link(args) do
    GenServer.start_link(__MODULE__, %{conn: args[:conn]}, name: args[:name])
  end

  @impl true
  def init(state) do
    note = Note.new()
    Process.send_after(self(), :send_midi, Enum.random(20..1000))
    {:ok, %{conn: state.conn, note: note}}
  end

  @impl true
  def handle_call(:get_conn, _from, state) do
    {:reply, state.conn, state}
  end

  @impl true
  def handle_cast(:send_midi, state) do
    Task.start(fn -> send_note(state) end)
    state = %{state | note: Note.new()}
    {:noreply, state}
  end

  @impl true
  def handle_info(:send_midi, state) do
    Task.start(fn -> send_note(state) end)

    # send a new note in a loop after the previous note has been sent
    Process.send_after(self(), :send_midi, Enum.random(20..1000))
    {:noreply, %{state | note: Note.new()}}
  end

  defp send_note(state) do
    %{note_on: note_on, note_off: note_off, duration: duration} = state.note
    Midiex.send_msg(state.conn, note_on)
    :timer.sleep(duration)
    Midiex.send_msg(state.conn, note_off)
  end
end
