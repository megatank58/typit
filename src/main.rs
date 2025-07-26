#![deny(clippy::all, clippy::nursery)]

mod handler;

use std::env;

use anyhow::Result;
use serenity::all::{ActivityData, Client, GatewayIntents};

use crate::handler::Handler;

#[tokio::main]
async fn main() -> Result<()> {
	dotenv::dotenv()?;

	let token = env::var("TOKEN")?;
	let intents = GatewayIntents::from_bits_retain(33280);

	let mut client = Client::builder(token, intents)
		.activity(ActivityData::playing("around with typst"))
		.event_handler(Handler)
		.await?;

	client.start().await?;

	Ok(())
}
