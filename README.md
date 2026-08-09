# `hypr`

Tiny Hyper key daemon for macOS 🪄

## Features

- While the Escape key is held down, it acts as if you're holding down ⌃⌥⌘⇧
  (Ctrl-Option-Command-Shift), also known as the Hyper key,
- otherwise, it acts like Escape.

... There are no other features, there is no configuration.

This is by design!

> [!TIP]
> You can map Caps Lock to Escape (and therefore to Hyper):
> System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys

## Installation

```sh
brew tap ElliottH/tap
brew install --cask ElliottH/tap/hypr
```

`hypr` will appear in your menu bar. You will be prompted to grant Accessibility
permissions, which it needs so that it can do its job.

It will add itself to Login Items automatically on first launch, so it starts
with your Mac. You can toggle this from the menu bar icon.

## Why?

So:

- why make this?
- why not use something else?
- why not be configurable?
- etc.

Everything with Accessibility permissions on macOS can read and modify
keystrokes from every application, so I wanted something that is:

- open-source (can be vetted)
- doesn't allow for arbitrary code execution (e.g. plugins, scripts)
- as limited in scope as possible (less risk)

... I also just wanted to see if I could. 🙃
