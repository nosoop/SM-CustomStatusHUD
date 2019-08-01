# Custom Status HUD

Provides a unified interface for plugins to write custom HUD content without having to deal
with their own positioning.

Intended for things like TF2 items being used on classes that normally can't equip them.

## Client Options

Provides the following cookies for clients to modify (these are not server convars!):

`statushud_xpos` and `statushud_ypos` control the positioning of the text display.
Negative values align the text to the right / bottom sides instead of top / left.
Defaults to (-0.2, -0.005).

`statushud_color` controls the color of the HUD element, in RGBA hex format.
