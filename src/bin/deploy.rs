use std::env;

use serenity::all::{Command, CommandOptionType, CreateCommand, CreateCommandOption, HttpBuilder};

#[tokio::main]
async fn main() {
    let application_id = env::var("APPLICATION_ID").unwrap().parse().unwrap();
    let token = env::var("DISCORD_TOKEN").unwrap();
    let http = HttpBuilder::new(token)
        .application_id(application_id)
        .build();

    let expr = CreateCommandOption::new(
        CommandOptionType::String,
        "expression",
        "The expression to evaluate (leave empty for modal)",
    );

    let typ = CreateCommand::new("typ")
        .description("Typeset a document based on provided typst code")
        .set_options(vec![expr]);

    Command::create_global_command(&http, typ).await.unwrap();
}
