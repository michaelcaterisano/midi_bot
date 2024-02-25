# MidiBot

iex -S mix

# start a midi server, passing the midiport two which Midiex should send messages. Defaults to an :output port.
{:ok, pid} = MidiBot.start_midi_server("IAC Driver Bus 1")

# trigger midiserver to send a note to its port
GenServer.cast(pid, :send_midi)



enjoy

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `midi_bot` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:midi_bot, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/midi_bot>.

