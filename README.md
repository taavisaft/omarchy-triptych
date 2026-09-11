# Triptych

A visual [Omarchy](https://omarchy.org/) shell plugin for switching the active
Hyprland workspace between layouts designed for ultrawide monitors.

Source: [taavisaft/omarchy-triptych](https://github.com/taavisaft/omarchy-triptych)

A triptych is a three-panel work: a dominant centre panel with a hinged wing
either side. That is the shape of this plugin's signature preset, and the
arrangement an ultrawide monitor wants.

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
omarchy plugin add https://github.com/taavisaft/omarchy-triptych.git --enable
```

The Triptych button appears in the right section of the Omarchy bar. Click
it and select a visual preset for the active workspace.

## Session behavior

The plugin changes only the current Hyprland session. It does not rewrite your
Hyprland configuration. A Hyprland reload or a new login restores the layout
configured in your Omarchy settings.

## Update or remove

```bash
omarchy plugin update triptych
omarchy plugin remove triptych
```

## Development and testing

```bash
git clone https://github.com/taavisaft/omarchy-triptych.git
omarchy plugin validate ./omarchy-triptych
```

For an installed copy, rescan and enable the plugin with:

```bash
omarchy-shell shell rescanPlugins
omarchy plugin enable triptych
```

The presets can also be tested directly:

```bash
~/.config/omarchy/plugins/triptych/triptych-apply center-master
~/.config/omarchy/plugins/triptych/triptych-apply left-master
~/.config/omarchy/plugins/triptych/triptych-apply equal-columns
```

## License

[MIT](LICENSE)
