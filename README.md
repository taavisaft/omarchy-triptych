# Conglomerate Marble

A visual [Omarchy](https://omarchy.org/) shell plugin for switching the active
Hyprland workspace between layouts designed for ultrawide monitors.

Source: [taavisaft/omarchy-conglomerate-marble](https://github.com/taavisaft/omarchy-conglomerate-marble)

## Features

- Visual preset cards that show each layout before it is applied
- A full-height center column with vertically split side columns
- A left-master layout with a vertical stack on the right
- Three equal scrolling columns
- A separate layout choice for every workspace during the current session

## Install

Omarchy plugins execute unsandboxed code as your user. Review the source before
installing, then run:

```bash
omarchy plugin add https://github.com/taavisaft/omarchy-conglomerate-marble.git --enable
```

The Marble button appears in the right section of the Omarchy bar. Click
it and select a visual preset for the active workspace.

## Session behavior

The plugin changes only the current Hyprland session. It does not rewrite your
Hyprland configuration. A Hyprland reload or a new login restores the layout
configured in your Omarchy settings.

## Update or remove

```bash
omarchy plugin update conglomerate.marble
omarchy plugin remove conglomerate.marble
```

## Development and testing

```bash
git clone https://github.com/taavisaft/omarchy-conglomerate-marble.git
omarchy plugin validate ./omarchy-conglomerate-marble
```

For an installed copy, rescan and enable the plugin with:

```bash
omarchy-shell shell rescanPlugins
omarchy plugin enable conglomerate.marble
```

The presets can also be tested directly:

```bash
~/.config/omarchy/plugins/conglomerate.marble/marble-apply center-master
~/.config/omarchy/plugins/conglomerate.marble/marble-apply left-master
~/.config/omarchy/plugins/conglomerate.marble/marble-apply equal-columns
```

## License

[MIT](LICENSE)
