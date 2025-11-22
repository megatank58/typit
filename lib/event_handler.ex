defmodule Typit.Consumer do
  @behaviour Nostrum.Consumer

  require Logger
  require Nosedrum.Storage.Dispatcher
  require Nosedrum.TextCommand.Invoker.Split
  require Nosedrum.TextCommand.Storage.ETS

  alias Nosedrum.Storage.Dispatcher
  alias Nosedrum.TextCommand.Invoker.Split
  alias Nosedrum.TextCommand.Storage.ETS

  def handle_event({:READY, _, _}) do
    Logger.info("Typit has started")
    
    ETS.add_command(["typ"], Typit.TextCommand)
    case Nosedrum.Storage.Dispatcher.add_command("typ", Typit.ApplicationCommand, :global) do
      {:ok, _} -> IO.puts("Registered command.")
      e -> IO.inspect(e, label: "An error occurred registering the command")
    end
  end

  def handle_event({:MESSAGE_CREATE, message, _}) do
    Logger.info("Message received!")
    Split.handle_message(message)
  end

  def handle_event({:INTERACTION_CREATE, intr, _}), do: Dispatcher.handle_interaction(intr)
  
  def handle_event(_), do: :noop
end


