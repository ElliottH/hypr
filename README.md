# `hypr`

Tiny Hyper key daemon for macOS 🪄

## Features

- While the Escape key is held down, it acts as if you're holding down ⌃⌥⌘⇧
  (a.k.a the Hyper key),
- otherwise, it acts like Escape.

... There are no other features, there is no configuration.

This is by design!

## Installation

```sh
brew tap ElliottH/hypr
brew install hypr
```

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
