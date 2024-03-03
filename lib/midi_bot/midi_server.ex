defmodule MidiBot.MidiServer do
  use GenServer

  alias MidiBot.Note

  def start_link(args) do
    GenServer.start_link(__MODULE__, %{name: args[:reference_name]}, name: args[:name])
  end

  @impl true
  def init(state) do
    intial_note = Note.new()
    virtual_output = Midiex.create_virtual_output(state[:name] |> to_string())
    Process.send_after(self(), :send_midi, Enum.random(20..1000))
    {:ok, %{port: virtual_output, note: intial_note}}
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

    # send a new note in a loop after the previous note has been sent
    Process.send_after(self(), :send_midi, Enum.random(20..1000))
    {:noreply, %{state | note: Note.new()}}
  end

  defp send_note(state) do
    %{note_on: note_on, note_off: note_off, duration: duration} = state.note
    Midiex.send_msg(state.port, note_on)
    :timer.sleep(duration)
    Midiex.send_msg(state.port, note_off)
  end
end
