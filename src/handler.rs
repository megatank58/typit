use serenity::all::{
	ActionRowComponent, ButtonKind, ButtonStyle, Context, CreateActionRow, CreateAttachment, CreateButton,
	CreateMessage, EventHandler, Interaction, Message, Ready,
};
use std::io::Write;
use std::process::{Command, Stdio};
use std::thread;

pub struct Handler;

#[serenity::async_trait]
impl EventHandler for Handler {
	async fn interaction_create(&self, ctx: Context, interaction: Interaction) {
		let button_interaction = interaction.message_component().unwrap();
		let ActionRowComponent::Button(btn) = &button_interaction.message.components[0].components[0] else {
			unreachable!()
		};

		let ButtonKind::NonLink { custom_id, style: _ } = &btn.data else {
			unreachable!()
		};

		if custom_id != &button_interaction.user.id.to_string() {
			return;
		}

		button_interaction.message.delete(&ctx).await.unwrap();
	}

	async fn message(&self, ctx: Context, message: Message) {
		if message.author.bot {
			return;
		}

		let mut is_math_equation = false;
		let mut is_math_equation_open = false;
		let mut last_char = None;

		for char in message.content.chars() {
			if char == '$' && is_math_equation_open {
				match last_char {
					Some(' ') => {}
					Some(..) => is_math_equation = true,
					None => unreachable!(),
				}
			}

			if last_char == Some('$') && char != ' ' {
				is_math_equation_open = true
			}

			last_char = Some(char);
		}

		if is_math_equation || message.content.starts_with(",typ") {
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
						&"#import \"@preview/catppuccin:1.0.0\": catppuccin, flavors\n#show: catppuccin.with(flavors.mocha)\n#set page(height: auto, width: auto, margin: 12pt)\n#set text(size: 32pt)\n\n"
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
						CreateMessage::new()
							.content(format!("**{}**", message.author.name))
							.components(vec![CreateActionRow::Buttons(vec![
								CreateButton::new("delete")
									.custom_id(message.author.id.to_string())
									.label("Delete")
									.emoji('🗑')
									.style(ButtonStyle::Danger),
							])]),
					)
					.await
					.unwrap();
			} else {
				message
					.channel_id
					.send_message(
						&ctx,
						CreateMessage::new()
							.content(format!("```hs\n{}\n```", String::from_utf8(output.stderr).unwrap()))
							.components(vec![CreateActionRow::Buttons(vec![
								CreateButton::new("delete")
									.label("Delete")
									.emoji('🗑')
									.style(ButtonStyle::Danger),
							])]),
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
