defmodule Typit do
  use Application
  require Dotenvy

  def start(_type, _args) do
    
    # Load environment variables
    Dotenvy.source!(
      [
        Path.expand(".env"),
        System.get_env()
      ],
      required_files: true
    )
    
    bot_options = %{
      consumer: Typit.Consumer,
      intents: [
        :guild_messages,
        :guilds,
        :message_content
      ],
      wrapped_token: fn -> Dotenvy.env!("DISCORD_TOKEN") end,
    }

    children = [
      Nosedrum.TextCommand.Storage.ETS,
      { Nostrum.Bot, bot_options }
    ]

    options = [strategy: :one_for_one, name: Typit.Supervisor]
    Supervisor.start_link(children, options)
  end
end
