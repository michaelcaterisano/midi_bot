defmodule MidiBot do
  use Application

  alias MidiBot.MidiServer

  def start(_type, _args) do
    children = [
      {MidiServer, []}
    ]

    opts = [strategy: :one_for_one, name: MidiBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
