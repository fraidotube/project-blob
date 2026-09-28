extends Node

const MENU_BUTTON_SCRIPT := preload(
	"res://scripts/ui/menu_button.gd"
)


func style_buttons(root: Node) -> void:
	_style_recursive(root)


func _style_recursive(node: Node) -> void:
	if node is Button:
		var button := node as Button

		if button.get_script() == null:
			button.set_script(
				MENU_BUTTON_SCRIPT
			)

	for child: Node in node.get_children():
		_style_recursive(child)
