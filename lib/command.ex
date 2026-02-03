defmodule Typit.TextCommand do
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
  def command(message, "") do
    response = "<text> is needed for generating image"
    {:ok, _message} = Nostrum.Api.Message.create(message.channel_id, response)
  end

  def command(message, _text) do
    contents = String.replace(message.content, ",typ", "")

    task = Task.async(fn -> Rambo.run("typst", ["compile", "-", "-", "--format", "png"], in: "#{Typit.Constants.setup()}\n#{contents}", timeout: Typit.Constants.time_limit()) end)

    try do
      case Task.await(task) do
        {:ok, results} -> Nostrum.Api.Message.create(message.channel_id, content: "**#{message.author.username}**", file: %{name: "output.png", body: results.out})
        {:error, results} -> Nostrum.Api.Message.create(message.channel_id, content: "```hs\n#{results.err}```")
      end
    catch
      :exit, _ -> Nostrum.Api.Message.create(message.channel_id, content: "Expression took more than #{Typit.Constants.time_limit()/1000} seconds to render.")
    end
  end
end

defmodule Typit.ApplicationCommand do
  @behaviour Nosedrum.ApplicationCommand
  @moduledoc false

  @impl true
  def description() do
    "generate an image of typst code"
  end

  @impl true
  def command(interaction) do
    if interaction.data.options != nil do
      defer_response = %{
        type: 5,
      }
  
      Nostrum.Api.Interaction.create_response(interaction, defer_response)

      contents = Enum.at(interaction.data.options, 0).value

      task = Task.async(fn -> Rambo.run("typst", ["compile", "-", "-", "--format", "png"], in: "#{Typit.Constants.setup()}\n$ #{contents} $", timeout: Typit.Constants.time_limit()) end)

      try do
        response = case Task.await(task) do
          {:ok, results} -> %{content: "**#{interaction.user.username}**", file: %{name: "output.png", body: results.out}}
          {:error, results} -> %{content: "```hs\n#{results.err}```"}
        end

        Nostrum.Api.Interaction.edit_response(interaction, response)
      catch
        :exit, _ -> Nostrum.Api.Interaction.edit_response(interaction,  %{content: "Expression took more than #{Typit.Constants.time_limit()/1000} seconds to render."})
      end
    else
      response = %{
        type: 9,
        data: %{
          custom_id: "typit_modal",
          title: "Typit Image Generation",
          components: [
            %{
               type: 1,
                components: [%{
                  type: 4,
                  custom_id: "code",
                  label: "Code",
                  style: 2,
                  placeholder: "Write your code here...",
                  required: true
              }]
            }
          ]
        }
      }

     Nostrum.Api.Interaction.create_response(interaction, response)
   end
  end

  @impl true
  def type() do
    :slash
  end

  @impl true
  def options() do
    [
      %{
        type: :string,
        name: "expression",
        description: "The expression for the bot to generate image in math mode.",
        required: false
      }
    ]
  end
end

defmodule Typit.Modal do
  @behaviour Nosedrum.ComponentInteraction
  @moduledoc false
  
  def message_component_interaction(interaction, _) do
    defer_response = %{
      type: 5,
    }
  
    Nostrum.Api.Interaction.create_response(interaction, defer_response)
    
    contents = Enum.at(Enum.at(interaction.data.components, 0).components,0).value

    task = Task.async(fn -> Rambo.run("typst", ["compile", "-", "-", "--format", "png"], in: "#{Typit.Constants.setup()}\n#{contents}", timeout: Typit.Constants.time_limit()) end)

    try do
      response = case Task.await(task) do
        {:ok, results} -> %{content: "**#{interaction.user.username}**", file: %{name: "output.png", body: results.out}}
        {:error, results} -> %{content: "```hs\n#{results.err}```"}
      end

      Nostrum.Api.Interaction.edit_response(interaction, response)
    catch
      :exit, _ -> Nostrum.Api.Interaction.edit_response(interaction,  %{content: "Expression took more than #{Typit.Constants.time_limit()/1000} seconds to render."})
    end
  end
end
