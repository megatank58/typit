#![deny(clippy::all, clippy::nursery)]

mod handler;

use std::env;

use serenity::all::{ActivityData, Client, GatewayIntents};

use crate::handler::Handler;

#[tokio::main]
async fn main() {
	dotenv::dotenv().unwrap();

	let token = env::var("TOKEN").unwrap();
	let intents = GatewayIntents::from_bits_retain(33280);

	let mut client = Client::builder(token, intents)
		.activity(ActivityData::playing("around with typst"))
		.event_handler(Handler)
		.await
		.unwrap();

	client.start().await.unwrap();
}
