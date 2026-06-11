use anyhow::Result;
use serenity::all::{
    ActionRowComponent, CommandInteraction, Context, CreateActionRow, CreateAllowedMentions,
    CreateAttachment, CreateInputText, CreateInteractionResponse, CreateInteractionResponseMessage,
    CreateMessage, CreateModal, EditAttachments, EditInteractionResponse, InputTextStyle, Message,
    ModalInteraction,
};
use std::{process::Stdio, time::Duration};
use tokio::io::{AsyncReadExt, AsyncWriteExt as _};

struct Content {
    text: String,
    attachment: Option<CreateAttachment>,
}

const PREAMBLE: &str = r#"
#import "@preview/catppuccin:1.0.0": catppuccin, flavors;
#show: catppuccin.with(flavors.mocha);
#set page(height: auto, width: auto, margin: 28pt);
#set text(size: 44pt);
"#;

async fn run_typst(content: &str) -> Result<Content> {
    let mut child = tokio::process::Command::new("typst")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .args(["compile", "-", "-", "--format", "png"])
        .spawn()?;

    let mut stdin = child.stdin.take().unwrap();
    stdin
        .write_all(format!("{PREAMBLE}\n{content}").as_bytes())
        .await?;
    drop(stdin);

    let mut buf = vec![];

    let mut stdout = child.stdout.take().unwrap();
    if tokio::time::timeout(Duration::from_secs(25), stdout.read_to_end(&mut buf))
        .await
        .is_err()
    {
        return Ok(Content {
            text: "Your code took too long (>25s) to run".to_owned(),
            attachment: None,
        });
    };

    let mut stderr = child.stderr.take().unwrap();
    stderr.read_to_end(&mut buf).await?;

    let stat = child.wait().await?;

    if stat.success() {
        let attachment = CreateAttachment::bytes(buf, "typst.png");

        Ok(Content {
            text: String::new(),
            attachment: Some(attachment),
        })
    } else {
        let err = String::from_utf8_lossy(&buf).into_owned();

        Ok(Content {
            text: format!("```typ\n{err}\n```"),
            attachment: None,
        })
    }
}

pub async fn typ_message(ctx: &Context, content: &str, msg: &Message) -> Result<()> {
    let mut content = content.trim().to_owned();

    if content.is_empty() {
        msg.reply_ping(
            &ctx,
            "You must provide code to typeset. Usage: `,typ [code]`",
        )
        .await?;
    }

    if content.starts_with("```") {
        let mut lines = content.lines();
        let _ = lines.next();
        let _ = lines.next_back();

        content = lines.collect::<String>();
    }

    let content = run_typst(&content).await?;
    let resp = CreateMessage::new()
        .content(content.text)
        .reference_message(msg)
        .files(content.attachment)
        .allowed_mentions(CreateAllowedMentions::new().empty_users());

    msg.channel_id.send_message(&ctx, resp).await?;

    Ok(())
}

pub async fn typ_interaction(ctx: &Context, cmd: &CommandInteraction) -> Result<()> {
    if cmd.data.options.is_empty() {
        let txt_inp = CreateInputText::new(InputTextStyle::Paragraph, "code", "typst_doc_body")
            .placeholder("$ 1 + 2 = 3 $")
            .required(true);
        let action_row = CreateActionRow::InputText(txt_inp);
        let modal =
            CreateModal::new("typst_modal_id", "Input your code").components(vec![action_row]);

        let resp = CreateInteractionResponse::Modal(modal);
        cmd.create_response(&ctx, resp).await?;
    } else {
        let code = cmd.data.options[0].value.as_str().unwrap();
        cmd.create_response(
            &ctx,
            CreateInteractionResponse::Defer(CreateInteractionResponseMessage::new()),
        )
        .await?;

        let content = run_typst(code).await?;

        let mut attachments = EditAttachments::new();

        if let Some(atch) = content.attachment {
            attachments = attachments.add(atch);
        }

        let msg = EditInteractionResponse::new()
            .content(content.text)
            .attachments(attachments);

        cmd.edit_response(&ctx, msg).await?;
    }

    Ok(())
}

pub async fn typ_modal(ctx: &Context, modal: &ModalInteraction) -> Result<()> {
    let ActionRowComponent::InputText(in_text) = modal.data.components[0].components[0].clone()
    else {
        unreachable!();
    };

    let code = in_text.value.unwrap();
    modal
        .create_response(
            &ctx,
            CreateInteractionResponse::Defer(CreateInteractionResponseMessage::new()),
        )
        .await?;
    let content = run_typst(&code).await.unwrap();

    let mut attachments = EditAttachments::new();

    if let Some(atch) = content.attachment {
        attachments = attachments.add(atch);
    }

    let msg = EditInteractionResponse::new()
        .content(content.text)
        .attachments(attachments);

    modal.edit_response(&ctx, msg).await?;

    Ok(())
}
