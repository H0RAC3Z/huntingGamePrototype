extends Button
class_name InventorySlot

signal OnItemEquipped(SlotID)
signal OnItemDropped(fromSlotID, toSlotID)
signal Tooltip()

const TOOLTIPS = preload("res://scenes/Tooltips.tscn")
@export var EquippedHighlight : Panel
@export var IconSlot : TextureRect

@onready var InteractionArea : Area3D = get_node("/root/Main/Player/InteractionArea")
@onready var InventoryUI : Control = get_node("/root/Main/Player/InventoryUI")
@onready var PlayerBody : CharacterBody3D = get_node("/root/Main/Player")
@onready var PlayerBodyCamera : Camera3D = get_node("/root/Main/Player/Camera3D")
@onready var tooltip : Tooltips = TOOLTIPS.instantiate()
var counter : int
var InventorySlotID : int = -1
var SlotFilled : bool = false
var equippable : bool = false
var equipped : bool = false


var SlotData : ItemData

func _ready() -> void:
	get_tree().get_current_scene().get_node("UI").add_child(tooltip)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			OnItemEquipped.emit(InventorySlotID)

func _physics_process(delta: float) -> void:
	if self.is_hovered() and SlotData != null and !tooltip.visible:
		tooltip.visible = true
		tooltip.global_position = get_viewport().get_mouse_position() + Vector2(20, 0)
		tooltip.set_display_name(self.SlotData.ItemName)
	elif self.is_hovered() and SlotData != null:
		tooltip.global_position = get_viewport().get_mouse_position() + Vector2(20, 0)
	else:
		tooltip.visible = false
		

func FillSlot(data : ItemData, equipped : bool):
	SlotData = data
	EquippedHighlight.visible = equipped
	if SlotData != null:
		SlotFilled = true
		IconSlot.texture = data.Icon
	else:
		SlotFilled = false
		IconSlot.texture = null
		
func _get_drag_data(at_position : Vector2) -> Variant:
	if SlotFilled:
		var preview : TextureRect = TextureRect.new()
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.size = IconSlot.size
		preview.pivot_offset = IconSlot.size / 2.0
		preview.rotation = 2.0
		preview.texture = IconSlot.texture
		set_drag_preview(preview)
		
		return {"Type" : "Item", "ID" : InventorySlotID}
	else:
		return false

func _can_drop_data(at_position : Vector2, data : Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data["Type"] == "Item"

func _drop_data(at_position : Vector2, data : Variant) -> void:
	OnItemDropped.emit(data["ID"], InventorySlotID)
	
func _unhandled_key_input(event: InputEvent) -> void:
	# if drop item key pressed while hover over not empty inventory slot, we drop!
	if event is InputEventKey and Input.is_action_just_pressed("drop_item") and self.is_hovered() and self.SlotFilled:
		if equipped:
			for n in PlayerBodyCamera.get_children():
				PlayerBodyCamera.remove_child(n)
				n.queue_free()
		counter = InteractionArea.getCounter()
		InteractionArea.setCounter(counter - 1) # update counter
	
		var newItem = self.SlotData.ItemModelPrefab.instantiate() as Node3D
		self.FillSlot(null, false)
	
		PlayerBody.get_parent().add_child(newItem)
		newItem.global_position = InventoryUI.GetWorldMousePosition()
