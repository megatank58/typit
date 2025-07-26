use serenity::all::{Context, CreateAttachment, CreateMessage, EventHandler, Message, Ready};
use std::io::Write;
use std::process::{Command, Stdio};
use std::thread;

pub struct Handler;

#[serenity::async_trait]
impl EventHandler for Handler {
	async fn message(&self, ctx: Context, message: Message) {
		if message.author.bot {
			return;
		}

		if message.content.chars().filter(|c| *c == '$').count() > 1 || message.content.starts_with(",typ") {
			let mut cmd = Command::new("typst")
				.args(["compile", "-", "-", "--format", "png"])
				.stdin(Stdio::piped())
				.stdout(Stdio::piped())
				.stderr(Stdio::piped())
				.spawn()
				.unwrap();

			let mut code = message.content.clone();

			code = match code.strip_prefix(",typ") {
				Some(new_code) => new_code.to_string(),
				None => code,
			};

			let mut stdin = cmd.stdin.take().expect("Failed to open stdin");

			thread::spawn(move || {
				stdin
					.write(
						&"#import \"@preview/catppuccin:1.0.0\": catppuccin, flavors\n#show: catppuccin.with(flavors.mocha)\n#set page(height: auto, width: auto, margin: 16pt)\n#set text(size: 20pt)\n\n"
							.bytes()
							.collect::<Vec<u8>>(),
					)
					.expect("Failed to write to stdin");
				stdin.write_all(code.as_bytes()).expect("Failed to write to stdin");
			});

			let output = cmd.wait_with_output().unwrap();

			if output.status.success() {
				message
					.channel_id
					.send_files(
						&ctx,
						vec![CreateAttachment::bytes(output.stdout, "output.png")],
						CreateMessage::new().content(format!("**{}**", message.author.name)),
					)
					.await
					.unwrap();
			} else {
				message
					.reply(
						&ctx,
						format!("```hs\n{}\n```", String::from_utf8(output.stderr).unwrap()),
					)
					.await
					.unwrap();
			}
		}
	}

	async fn ready(&self, _: Context, ready: Ready) {
		println!("{} is running!", ready.user.name);
	}
}
