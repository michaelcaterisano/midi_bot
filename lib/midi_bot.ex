defmodule MidiBot do
  use Application

  alias MidiBot.MidiServer

  def start(_type, _arg) do
    children = [
      Supervisor.child_spec(
        {MidiServer, %{port_name: "IAC Driver Bus 1", server_name: :midi_server_1}},
        id: :midi_server_1
      ),
      Supervisor.child_spec(
        {MidiServer, %{port_name: "IAC Driver Bus 2", server_name: :midi_server_2}},
        id: :midi_server_2
      )
    ]

    opts = [strategy: :one_for_one, name: MidiBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
