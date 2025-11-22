defmodule Typit.TextCommand do
  @behaviour Nosedrum.TextCommand
  @moduledoc false

  require Rambo
  require Logger

  @time_limit 5_000
  @setup "#import \"@preview/catppuccin:1.0.0\": catppuccin, flavors;#show: catppuccin.with(flavors.mocha);#set page(height: auto, width: auto, margin: 28pt);#set text(size: 44pt);"
  
  @impl true
  def usage, do: [",typ <text>"]

  @impl true
  def description, do: "generate an image of typst code"

  @impl true
  def parse_args(args), do: Enum.join(args, " ")

  @impl true
  def predicates, do: []

  @impl true
  def command(message, "") do
    response = "<text> is needed for generating image"
    {:ok, _message} = Nostrum.Api.Message.create(message.channel_id, response)
  end

  def command(message, _text) do
    contents = String.replace(message.content, ",typ", "")

    task = Task.async(fn -> Rambo.run("typst", ["compile", "-", "-", "--format", "png"], in: "#{@setup}\n#{contents}", timeout: @time_limit) end)

    case Task.await(task) do
      {:ok, results} -> Nostrum.Api.Message.create(message.channel_id, content: "**#{message.author.username}**", file: %{name: "output.png", body: results.out})
      {:error, results} -> Nostrum.Api.Message.create(message.channel_id, content: "```hs\n#{results.err}```")
      {:killed, _} -> Nostrum.Api.Message.create(message.channel_id, content: "Expression took more than #{@time_limit/1000} seconds to render.")
    end
  end
end

defmodule Typit.ApplicationCommand do
  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description() do
    "generate an image of typst code"
  end

  @impl true
  def command(interaction) do
    
  end

  @impl true
  def type() do
    :slash
  end

  
  @impl true
  def options() do
    [
      %{
        type: :attachment,
        name: "file",
        description: "The file for the bot to generate image.",
        required: false
      }
    ]
  end
end
