# NAMPanels v0.1.0
Custom UI Script for Figura that paints over the ActionWheel.

# Installation

- 1: Download `nampanels.lua` from this repository, and add it to your main avatar's folder.
- 2: In your main script, add `local nampanels = require("nampanels")`. (Recommended to include at the beginning of your script.)
- 3: Add `panels.json` somewhere the script has read access. Be sure to call `api.config` with the path that the script should read panel data from.
- 4: From here, you can program in your own element types and structuring with relative ease.
- 5: Once programmed, use your actionwheel key to enable the UI.
- 6: Enjoy!

# Documentation

## panels.json
This file handles the data that element types should use once loaded. For any base element, such as a `div` or `body` (HTML5 terminology, but you can use any name), you can set the `type` property of an array to it and nest other elements inside it. This only works if the element is set to allow nesting; explained in api documentation.

Example:
```
{
	"Body": {
		"a": {...},
		"b": {...},
		"type": "div"
	}
}
```

When loaded, elements can read from these arrays to allow for things like toggles or variable inputs; explained in api documentation.

## api.newAction(name, func)
Creates a function that can be linked to in `panels.json` using the `func` component.
- `name`: Name of the function.
- `func`: The function itself. Accepts any arguments based on what is given in the element type.

## api.addElementType(name, attr, nestble)
Creates a new element type that the script can refer to when reading `panels.json`.
- `name`: Name of the element.
- `attr`: Table consisting of attributes that make up the element
  - `init`: Function to initialize things such as sprites/graphics or certain values. Accepts parameters `part`, the modelPart that the element is anchored to, and `vars`, a table of the element itself.
  - `func`: Function that runs every frame while this element is loaded.
    - `vars`: Element table.
    - `pos`: True position of the element, accounting for the elements it's nested in.
    - `descend`: All descendants of the element, if the `nestable` argument is true.
    - `coords`: Position of the cursor.
    - `clickState`: Click state of the mouse, deriving from `events.mouse_press`
    - `scroll`: Scroll delta of the mouse, deriving from `events.mouse_scroll`

## api.config(path)
- `path`: Directory pointing to `panels.json` for the script to load data from.
