# typit

Discord bot to compile typst to PNG.

## Requirements

* Message content intent is required for the text command to function.
* typst installed and avaliable in PATH.

## Usage

### ,typ expr (message command)

```
,typ

= Multiple lines of code

$ "equations" $
```

### /typ expression: expr (slash command)

Note: this runs in math mode.

```
/typ expression: `F = m a`
```

### /typ (modal)

Opens a modal to write 4000 characters of typst code.
```
/typ

OPENS MODAL
```
