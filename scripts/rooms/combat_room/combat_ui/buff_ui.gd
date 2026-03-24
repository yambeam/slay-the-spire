class_name BuffUI
extends TextureRect

var buff: Buff
@onready var stack_label: Label = $StackLabel

func _ready() -> void:
	texture = buff.icon
	update_stack()
	buff.stack_changed.connect(update_stack)
	buff.tree_exited.connect(_on_buff_removed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update_stack():
	if stack_label:
		stack_label.text = str(buff.stacks) if buff.stacks > 1 else ""
	
func _on_buff_removed() -> void:
	queue_free()

func _on_mouse_entered():
	if buff:
		Events.tooltip_show_request.emit(self)

func _on_mouse_exited():
	if buff:
		Events.tooltip_hide_request.emit()

func show_keyword_tooltip() -> void:
	if not buff:
		return
	KeywordTooltip.add_keyword(buff.buff_name, buff.get_description())
	KeywordTooltip.keyword_tooltip.global_position = global_position + Vector2(size.x * 2, 0)
