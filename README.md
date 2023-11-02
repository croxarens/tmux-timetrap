# Timetrap Wrapper For TMUX
A wrapper for [**timetrap**](https://github.com/samg/timetrap) from TMUX.

![demo](https://raw.githubusercontent.com/croxarens/public-assets/master/tmux-timetrap/demo.gif)


## Features
- Display in the status line the current tracked sheet and entry
- Start tracking time from a past or new entrty in an existing or new sheet
- Stop tracking time

## Plugin Installation
You need to have installed:
- [Tmux](https://github.com/tmux/tmux/wiki/Installing)
- [Tmux Plugin Manager (**TPM**)](https://github.com/tmux-plugins/tpm#installing-plugins)
- [**Timetrap**](https://github.com/samg/timetrap#getting-started)
- [fzf](https://github.com/junegunn/fzf#installation)

If all the above are successfully running in your system, you need to add the following line into your `.tmux.conf` file.

`set -g @plugin 'croxarens/tmux-timetrap'`

Than, using TPM, you can install the new plugin hitting `prefix` + `I`, and TPM will do the rest.


## Status Bar Installation
![demo-status-bar](https://raw.githubusercontent.com/croxarens/public-assets/master/tmux-timetrap/demo-status-bar.png)
To have the current tracked entries in the TMUX status bar, you need to add the following line into your `.tmux.conf` file.

`set -g status-right "#($HOME/.tmux/plugins/tmux-timetrap/scripts/status-bar.sh)"`

The referesh rate is 15 seconds by default in TMUX, so if you want refresh it more ofter so what when you start/stop a new tracking it quickly reflects on the status bar, you may add the following line into your `.tmux.conf` file:

`set -g status-interval 3     # update the status bar every 3 seconds`


## Key bindings

- `prefix` + `A` -> To start tracking an existing entity or a new entity.
- `prefix` + `S` -> To stop tracking

**Please keep in mind**: When starting a new tracking, if the entry you want is not in the menu you can create a new one by typing the name of the sheet (even if new) folloing with a dot (.) and the name of entry `{sheet name}.{entity name}`.

So, typing `companyX.bug-fixing` will start tracking a new entry named '**bug-fixing**' in the '**companyX**' sheet.