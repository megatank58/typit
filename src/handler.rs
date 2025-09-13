use serenity::all::{
	ActionRowComponent, ButtonKind, ButtonStyle, Context, CreateActionRow, CreateAttachment, CreateButton,
	CreateMessage, EventHandler, Interaction, Message, MessageUpdateEvent, Ready,
};
use std::io::Write;
use std::process::{Command, Stdio};
use std::thread;
use std::time::Duration;

const TIME_LIMIT: u64 = 5000;
const TIME_STEP: u64 = 50;
const PREAMBLE: &str = "#import \"@preview/catppuccin:1.0.0\": catppuccin, flavors\n#show: catppuccin.with(flavors.mocha)\n#set page(height: auto, width: auto, margin: 12pt)\n#set text(size: 32pt)\n\n";

fn is_math_block(contents: &str) -> bool {
	let mut is_math_block = contents.starts_with(",typ");
	let mut is_math_equation_open = false;
	let mut last_char = None;

	for char in contents.chars() {
		if is_math_block {
			break;
		}
		if char == '$' && is_math_equation_open {
			match last_char {
				Some(' ') => {}
				Some(..) => {
					is_math_block = true;
					break;
				}
				None => unreachable!(),
			}
		}

		if last_char == Some('$') && char != ' ' {
			is_math_equation_open = true
		}

		last_char = Some(char);
	}

	is_math_block
}

async fn preprocess(ctx: &Context, message: &Message) -> String {
	let mut code = message.content_safe(ctx);

	code = match code.strip_prefix(",typ") {
		Some(new_code) => new_code.to_string(),
		None => code,
	};

	if let Some(guild_id) = message.guild_id {
		for mentioned in &message.mention_channels {
			let mention = mentioned.id.to_string();

			if let Some(guild) = &ctx.cache.as_ref().guild(guild_id) {
				if let Some(channel) = guild.channels.get(&mentioned.id) {
					code = code.replace(&mention, &format!("#{}", channel.name));
					continue;
				}
			}
		}

		let channels = &guild_id.channels(&ctx).await.unwrap();

		for (id, channel) in channels {
			let mention = format!("<#{id}>");

			code = code.replace(&mention, &format!("#{}", channel.name));
			continue;
		}
	}

	code
}

fn compile(code: String, infinite_time: bool) -> Option<(bool, Vec<u8>)> {
	let mut cmd = Command::new("typst")
		.args(["compile", "-", "-", "--format", "png"])
		.stdin(Stdio::piped())
		.stdout(Stdio::piped())
		.stderr(Stdio::piped())
		.spawn()
		.unwrap();

	let mut stdin = cmd.stdin.take().expect("Failed to open stdin");

	thread::spawn(move || {
		stdin
			.write_all(&PREAMBLE.bytes().collect::<Vec<u8>>())
			.expect("Failed to write to stdin");
		stdin.write_all(code.as_bytes()).expect("Failed to write to stdin");
	});

	let mut milliseconds = 0;

	if !infinite_time {
		loop {
			let recv = cmd.try_wait();

			if recv.is_ok() && recv.unwrap().is_some() {
				break;
			}

			if milliseconds == TIME_LIMIT {
				let recv = cmd.try_wait();
				if recv.is_err() || (recv.is_ok() && recv.unwrap().is_none()) {
					cmd.kill().unwrap();
					return None;
				}
				break;
			}

			thread::sleep(Duration::from_millis(TIME_STEP));

			milliseconds += TIME_STEP;
		}
	}

	let output = cmd.wait_with_output().unwrap();

	Some((
		output.status.success(),
		if output.status.success() {
			output.stdout
		} else {
			output.stderr
		},
	))
}

async fn handle(ctx: Context, message: Message) {
	if message.author.bot || !is_math_block(&message.content) {
		return;
	}

	let code = preprocess(&ctx, &message).await;
	let result = compile(
		code,
		message.author.id == ctx.http.get_current_application_info().await.unwrap().owner.unwrap().id,
	);

	if result.is_none() {
		message
			.channel_id
			.send_message(
				&ctx,
				CreateMessage::new()
					.content("Expression took more than 3 seconds to render.")
					.components(vec![CreateActionRow::Buttons(vec![
						CreateButton::new("delete")
							.label("Delete")
							.emoji('🗑')
							.style(ButtonStyle::Danger),
					])]),
			)
			.await
			.unwrap();

		return;
	}

	let (success, response) = result.unwrap();

	if !success {
		message
			.channel_id
			.send_message(
				&ctx,
				CreateMessage::new()
					.content(format!("```hs\n{}\n```", String::from_utf8(response).unwrap()))
					.components(vec![CreateActionRow::Buttons(vec![
						CreateButton::new("delete")
							.label("Delete")
							.emoji('🗑')
							.style(ButtonStyle::Danger),
					])]),
			)
			.await
			.unwrap();

		return;
	}

	message
		.channel_id
		.send_files(
			&ctx,
			vec![CreateAttachment::bytes(response, "output.png")],
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
}

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
		handle(ctx, message).await;
	}

	async fn message_update(
		&self,
		ctx: Context,
		_old_message: Option<Message>,
		message: Option<Message>,
		_event: MessageUpdateEvent,
	) {
		if message.is_some() {
			handle(ctx, message.unwrap()).await;
		}
	}

	async fn ready(&self, _: Context, ready: Ready) {
		println!("{} is running!", ready.user.name);
	}
}
