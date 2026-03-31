# StandUpApp

Minimal macOS menu bar app that watches for keyboard and mouse activity and reminds you to stand up after a long coding streak.

## What it does

- Starts tracking when you type, click, scroll, or move the mouse
- Resets the work streak if you go idle for a few minutes
- Sends a macOS notification
- Speaks: "Get up stand up. Stand up for your health."
- Lives in the menu bar instead of the Dock

## Run it

```bash
cd /Users/mikegyi/LocalDev/stand-up-app
swift run
```

On first run, macOS may ask for:

- Notifications permission, so the reminder can appear
- Accessibility or Input Monitoring permission, depending on how your Mac handles global event monitoring

If you do not see the timer reacting to activity, open:

`System Settings -> Privacy & Security`

Then allow the terminal or built app to monitor input.
