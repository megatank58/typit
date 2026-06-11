use std::env;

use serenity::all::{CreateInteractionResponse, CreateInteractionResponseMessage, Interaction};
use serenity::async_trait;
use serenity::model::channel::Message;
use serenity::model::gateway::Ready;
use serenity::prelude::*;

mod commands;

struct Handler;

#[async_trait]
impl EventHandler for Handler {
    async fn message(&self, ctx: Context, msg: Message) {
        let Some(content) = msg.content.strip_prefix(",typ") else {
            return;
        };

        if let Err(err) = commands::typ_message(&ctx, content, &msg).await {
            msg.reply(&ctx, format!(":no_entry_sign: Error: {err}"))
                .await
                .unwrap();
        }
    }

    async fn interaction_create(&self, ctx: Context, interaction: Interaction) {
        match interaction {
            Interaction::Command(cmd) => {
                if cmd.data.name != "typ" {
                    return;
                }

                if let Err(err) = commands::typ_interaction(&ctx, &cmd).await {
                    let msg = CreateInteractionResponseMessage::new()
                        .content(format!(":no_entry_sign: Error: {err}"));

                    cmd.create_response(&ctx, CreateInteractionResponse::Message(msg))
                        .await
                        .unwrap();
                }
            }
            Interaction::Modal(modal) => {
                if let Err(err) = commands::typ_modal(&ctx, &modal).await {
                    let msg = CreateInteractionResponseMessage::new()
                        .content(format!(":no_entry_sign: Error: {err}"));

                    modal
                        .create_response(&ctx, CreateInteractionResponse::Message(msg))
                        .await
                        .unwrap();
                }
            }
            _ => todo!(),
        }
    }

    async fn ready(&self, _: Context, ready: Ready) {
        println!("{} is connected!", ready.user.name);
    }
}

#[tokio::main]
async fn main() {
    let token = env::var("DISCORD_TOKEN").expect("Expected a token in the environment");
    let intents = GatewayIntents::GUILD_MESSAGES | GatewayIntents::MESSAGE_CONTENT;

    let mut client = Client::builder(&token, intents)
        .event_handler(Handler)
        .await
        .expect("Err creating client");

    if let Err(why) = client.start().await {
        println!("Client error: {why:?}");
    }
}
