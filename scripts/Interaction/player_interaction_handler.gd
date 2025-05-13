extends Area3D

signal OnItemPickedUp(item)
signal HonkShooo(sleep : bool)

@export var ItemTypes : Array[ItemData] = []

@onready var InventoryUI : Control = $"../InventoryUI"
var ItemSlotsCount : int
var counter = 0
var NearbyBodies : Array[InteractableItem]

func _ready() -> void:
	ItemSlotsCount = InventoryUI.getItemSlots()

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("interact") and counter < ItemSlotsCount and NearbyBodies.size() > 0:
		counter += 1
		PickupNearestItem()

func PickupNearestItem() -> void:
	var nearestItem : InteractableItem = null
	var nearestItemDistance : float = INF
	for item in NearbyBodies:
		if item.global_position.distance_to(global_position) < nearestItemDistance:
			nearestItemDistance = item.global_position.distance_to(global_position)
			nearestItem = item
		
		if nearestItem.scene_file_path == ItemTypes[4].ItemModelPrefab.resource_path:
			HonkShooo.emit(true)
			counter -= 1
			return
		
		if nearestItem != null:
			nearestItem.queue_free()
			NearbyBodies.remove_at(NearbyBodies.find(nearestItem))
			var itemPrefab = nearestItem.scene_file_path
			for i in ItemTypes.size():
				if ItemTypes[i].ItemModelPrefab != null and ItemTypes[i].ItemModelPrefab.resource_path == itemPrefab:
					print("Item id: " + str(i) + " Item name: " + ItemTypes[i].ItemName)
					OnItemPickedUp.emit(ItemTypes[i])
					return
			
			printerr("Item not found!")

func OnObjectEnteredArea(body : Node3D):
	if body is InteractableItem:
		print("hi")
		body.GainFocus()
		NearbyBodies.append(body)
		
func OnObjectExitedArea(body : Node3D):
	if body is InteractableItem and NearbyBodies.has(body):
		body.LoseFocus()
		NearbyBodies.remove_at(NearbyBodies.find(body))

func getCounter() -> int:
	return self.counter

func setCounter(value : int) -> void:
	self.counter = value
