# NAMPanels v0.0.0
Custom UI Script for Figura that paints over the ActionWheel.

# Installation

- 1: Download `nampanels.lua` from this repository.
- 2: Add script to your main avatar's folder or in `./figura/data`, making sure to link to the script somewhere in your autoScripts. (In your autoScript, you can perform `loadstring(file:readString("./nampanels.lua"))` instead of `require`.)
- 3: In your main script, add `local nampanels = require("nampanels")`. (Recommended to include at the beginning of your script.)
- 4: Add `panels.json` somewhere the script has read access.
- 5: Enjoy!

# Documentation

## panels.json
This file controls what elements should exist on which page. In this file, certain element types can be defined:
  - No type: Treated as a link to another page, and will use the `button` type.
  - `button`: Simplest of the bunch; will trigger a callback once clicked.
    - `func`: Function to callback to.
  - `slider`: Slider bar that allows an input between a minimum and maximum range.
    - `range`: Array that specifies the range the slider can output.
    - `func`: Function to callback to.
  - `radio`: Similar to `button`, but provides multiple options for the same function.
    - `options`: Array with all options this element has available.
    - `func`: Function to callback to.

Example of `panels.json`'s structure:
```lua
{
	"Page1": {
		"Button": {
			"type": "button",
			"func": "myFunction"
		},
		"Slider": {
			"type": "slider",
			"func": "mySliderFunction",
			"range": [-2, 10]
		}
	},
	"Page2": {
		"Radio": {
			"type": "radio",
			"func": "myRadioFunction",
			"options": [
				1,
				2,
				3
			]
		}
	}
}
```

## api.newAction(name, func)
Creates a function that can be linked to in `panels.json` using the `func` component.
- `name`: Name of the function.
- `func`: The function itself. Accepts a single argument `value` that varies depending on the element type.
