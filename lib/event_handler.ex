defmodule Typit.Consumer do
  @behaviour Nostrum.Consumer

  require Logger
  require Nosedrum.TextCommand.Invoker.Split
  require Nosedrum.TextCommand.Storage.ETS
  
  alias Nosedrum.TextCommand.Invoker.Split
  alias Nosedrum.TextCommand.Storage.ETS

  def handle_event({:READY, _, _}) do
    Logger.info("Typit has started")
    ETS.add_command(["typ"], Typit.Command)
  end
  def handle_event({:MESSAGE_CREATE, message, _}) do
    Logger.info("Message received!")
    Split.handle_message(message)
  end 
  def handle_event(_), do: :noop
end


