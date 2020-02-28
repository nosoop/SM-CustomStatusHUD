# Custom Status HUD

Provides a unified interface for plugins to write custom HUD content without having to deal
with their own positioning.  Basically a glorified wrapper around `SyncHud`.

## Server Options

`statushud_update_interval` controls the time between HUD refresh intervals.  A higher number
means that plugins will update the value less often.

## Client Options

Provides the following cookies for clients to modify (these are not server convars!):

`statushud_xpos` and `statushud_ypos` control the positioning of the text display.
Negative values align the text to the right / bottom sides instead of top / left.
Defaults to (-0.2, -0.005).

`statushud_color` controls the color of the HUD element, in RGBA hex format.
