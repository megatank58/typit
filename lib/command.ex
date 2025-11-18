defmodule Typit.Command do
@behaviour Nosedrum.TextCommand
@moduledoc false

  @impl true
  def usage, do: [",typ <text>"]

  @impl true
  def description, do: "generate an image of typst code"

  @impl true
  def parse_args(args), do: Enum.join(args, " ")

  @impl true
  def predicates, do: []

  @impl true
  def command(msg, "") do
    response = "<text> is needed for generating image"
    {:ok, _msg} = Nostrum.Api.Message.create(msg.channel_id, response)
  end

  def command(msg, text) do
    {:ok, _msg} = Nostrum.Api.Message.create(msg.channel_id, text)
  end
end

