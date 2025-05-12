extends Control
class_name InventoryHandler

@export_flags_3d_physics var CollisionMask : int

@export var ItemSlotsCount : int = 40

@export var InventoryGrid : GridContainer
@export var InventorySlotPrefab : PackedScene = preload("res://scenes/InventorySlot.tscn")

@onready var InteractionArea : Area3D = $"../InteractionArea"
@onready var PlayerBody : CharacterBody3D = $".."
@onready var PlayerBodyCamera : Camera3D = $"../Camera3D"
var counter : int
var EquippedSlot : int = -1
var InventorySlots : Array[InventorySlot] = []

func _ready() -> void:
	for i in ItemSlotsCount:
		var slot = InventorySlotPrefab.instantiate() as InventorySlot
		InventoryGrid.add_child(slot)
		slot.InventorySlotID = i
		slot.OnItemDropped.connect(ItemDroppedOnSlot.bind())
		slot.OnItemEquipped.connect(ItemEquipped.bind())
		InventorySlots.append(slot)

# handles press i to open the inventory
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Input.is_action_just_pressed("inventory"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		visible = true
		PlayerBody.setVisibility(visible)
	elif event is InputEventKey and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and Input.is_action_just_pressed("inventory"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		visible = false
		PlayerBody.setVisibility(visible)

func PickupItem(item : ItemData):
	var foundSlot : bool = false
	counter = InteractionArea.getCounter() # update counter
	
	# fill InventorySlots arr with InventorySlot objects
	for slot in InventorySlots:
		if !slot.SlotFilled:
			slot.FillSlot(item, false)
			foundSlot = true
			break
	
	# spit back out if slot is not found
	if !foundSlot:
		var newItem = item.ItemModelPrefab.instantiate() as Node3D
		
		PlayerBody.get_parent().add_child(newItem)
		newItem.global_position = PlayerBody.global_position + PlayerBody.global_transform.basis.x * 2.0

func ItemEquipped(slotID : int):
	# unequipping
	if EquippedSlot != -1:
		InventorySlots[EquippedSlot].FillSlot(InventorySlots[EquippedSlot].SlotData, false)
		for n in PlayerBodyCamera.get_children():
			PlayerBodyCamera.remove_child(n)
			n.queue_free()
		
	
	# if slot id is not the current item equipped and is not nothing, then equip. Otherwise, we set -1
	if slotID != EquippedSlot and InventorySlots[slotID].SlotData != null:
		InventorySlots[slotID].FillSlot(InventorySlots[slotID].SlotData, true)
		EquippedSlot = slotID
		var equipItem = InventorySlots[slotID].SlotData.ItemModelPrefab.instantiate() as Node3D
		
		PlayerBodyCamera.add_child(equipItem)
		equipItem.script = null
		if equipItem is RigidBody3D:
			equipItem.freeze = true
		# disable all colliders in the equipItem
		for child in equipItem.get_children():
			if child is CollisionShape3D:
				child.set_deferred("disabled", true)
		
		# equip position from predefined optimal equip placement
		equipItem.transform.origin = InventorySlots[slotID].SlotData.OptimalEquipPlacement
	else:
		InventorySlots[EquippedSlot].equipped = false
		EquippedSlot = -1
		for n in PlayerBodyCamera.get_children():
			PlayerBodyCamera.remove_child(n)
			n.queue_free()
			
	if EquippedSlot == -1:
		return
	for i in ItemSlotsCount:
		if i == EquippedSlot:
			InventorySlots[i].equipped = true
	

func ItemDroppedOnSlot(fromSlotID : int, toSlotID : int):
	if EquippedSlot != -1:
		if EquippedSlot == fromSlotID:
			InventorySlots[fromSlotID].equipped = false
			InventorySlots[toSlotID].equipped = true
			EquippedSlot = toSlotID
		elif EquippedSlot == toSlotID:
			InventorySlots[fromSlotID].equipped = true
			InventorySlots[toSlotID].equipped = false
			EquippedSlot = fromSlotID
	
	var toSlotItem = InventorySlots[toSlotID].SlotData
	var fromSlotItem = InventorySlots[fromSlotID].SlotData
	
	InventorySlots[toSlotID].FillSlot(fromSlotItem, EquippedSlot == toSlotID)
	InventorySlots[fromSlotID].FillSlot(toSlotItem, EquippedSlot == fromSlotID)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data["Type"] == "Item"

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if EquippedSlot == data["ID"]:
		EquippedSlot = -1
		for n in PlayerBodyCamera.get_children():
			PlayerBodyCamera.remove_child(n)
			n.queue_free()
	InteractionArea.setCounter(counter - 1) # update counter
	
	var newItem = InventorySlots[data["ID"]].SlotData.ItemModelPrefab.instantiate() as Node3D
	InventorySlots[data["ID"]].FillSlot(null, false)
	
	PlayerBody.get_parent().add_child(newItem)
	newItem.global_position = GetWorldMousePosition()

func GetWorldMousePosition() -> Vector3:
	var mousePos = get_viewport().get_mouse_position()
	var cam = get_viewport().get_camera_3d()
	var ray_start = cam.project_ray_origin(mousePos)
	var ray_end = ray_start + cam.project_ray_normal(mousePos) * cam.global_position.distance_to(PlayerBody.global_position) * 2.0
	var world3d : World3D = PlayerBody.get_world_3d()
	var space_state = world3d.direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, CollisionMask)
	
	var results = space_state.intersect_ray(query)
	if results:
		return results["position"] as Vector3 + Vector3(0.0, 0.5, 0.0)
	else:
		return ray_start.lerp(ray_end, 0.5) + Vector3(0.0, 0.5, 0.0)
	
func getItemSlots() -> int:
	return self.ItemSlotsCount
