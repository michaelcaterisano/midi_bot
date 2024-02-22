defmodule MidiBot do
  alias MidiBot.MidiServer

  def start do
    MidiServer.start()

    iac = MidiServer.port_by_name("IAC Driver Bus 1", :output)
    MidiServer.set_port(iac)
  end
end
