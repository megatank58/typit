defmodule Typit.Consumer do
  @behaviour Nostrum.Consumer

  require Logger
  require Nosedrum

  def handle_event({:READY, _, _}) do
    Logger.info("Typit started")
    
    Nosedrum.TextCommand.Storage.ETS.add_command(["typ"], Typit.TextCommand)
    Nosedrum.ComponentHandler.ETS.register_components(["typit_modal"], Typit.Modal, nil)
    case Nosedrum.Storage.Dispatcher.add_command("typ", Typit.ApplicationCommand, :global) do
      {:ok, _} -> Logger.info("Registered command")
      e -> Logger.error("An error occurred registering the command: #{e}")
    end
  end

  def handle_event({:MESSAGE_CREATE, message, _}) , do: Nosedrum.TextCommand.Invoker.Split.handle_message(message)

  def handle_event({:INTERACTION_CREATE, interaction, _}) do
    case interaction.type do
      1 -> Nostrum.Api.Interaction.create_response(interaction, %{type: 1})
      2 -> Nosedrum.Storage.Dispatcher.handle_interaction(interaction)
      x when x in 3..5 -> Nosedrum.ComponentHandler.ETS.handle_component_interaction(interaction)
    end
  end 
  
  def handle_event(_), do: :noop
end


