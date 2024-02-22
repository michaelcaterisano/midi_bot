defmodule MidiBot.Note do
  @enforce_keys [:note_on, :note_off, :duration]
  defstruct note_on: nil, note_off: nil, duration: nil

  @default_note_duration 2000

  def new do
    note_on = Midiex.Message.note_on(Enum.random(40..80), Enum.random(40..80), channel: 0)
    <<_, note, _>> = note_on
    note_off = Midiex.Message.note_off(note, 127, channel: 0)

    %__MODULE__{note_on: note_on, note_off: note_off, duration: @default_note_duration}
  end
end
