defmodule MidiBot.MidiServer do
  @name :midi_server

  use GenServer

  alias MidiBot.Note

  def start do
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  @impl true
  def init(_state) do
    port = port_by_name("IAC Driver Bus 1", :output)
    IO.inspect(port, label: "Port")
    Process.send_after(self(), :send_midi, Enum.random(20..1000))
    {:ok, %{port: Midiex.open(port), note: Note.new()}}
  end

  def set_port(port) do
    GenServer.call(@name, {:set_port, port})
  end

  def get_port do
    GenServer.call(@name, :get_port)
  end

  def get_ports do
    Midiex.ports()
  end

  def port_by_name(name, direction) do
    Midiex.ports(name, direction) |> List.first()
  end

  @impl true
  def handle_call(:get_port, _from, state) do
    {:reply, state.port, state}
  end

  def handle_call({:set_port, port}, _from, state) do
    Process.send_after(self(), :send_midi, Enum.random(20..1000))
    {:reply, port, %{state | port: Midiex.open(port)}}
  end

  @impl true
  def handle_info(:send_midi, state) do
    Task.start(fn -> send_note(state) end)
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
