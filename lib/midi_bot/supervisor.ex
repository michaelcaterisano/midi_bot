defmodule MidiBot.Supervisor do
  use Supervisor

  def start_link do
    IO.inspect("starting supervisor")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      MidiBot.MidiSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
