extends RigidBody3D

const venison = preload("res://scenes/Venison.tscn")
const meat = preload("res://scenes/Meat.tscn")
const testTree = preload("res://scenes/testTree.tscn")
@onready var item_types : Array[ItemData] = get_node("/root/Main/Player/InteractionArea").ItemTypes
@onready var item_v : ItemData = item_types[6]
@onready var item_m : ItemData = item_types[5]
@onready var item_t_t : ItemData = item_types[2]
var v = venison.instantiate()
var m = meat.instantiate()
var t_t = testTree.instantiate()

func _ready() -> void:
	var label1 = get_node("/root/Main/Shop/Stand1/Label")
	var label2 = get_node("/root/Main/Shop/Stand2/Label")
	var label3 = get_node("/root/Main/Shop/Stand3/Label")
	add_child(v)
	add_child(m)
	add_child(t_t)
	v.freeze = true
	m.freeze = true
	t_t.freeze = true
	v.position = Vector3(-10.377, 2, -2)
	m.position = Vector3(0, 2, -2)
	t_t.position = Vector3(10.377, 2, -2)
	label1.text = item_v.ItemName + "\n Price : " + str(item_v.Value)
	label2.text = item_m.ItemName + "\n Price : " + str(item_m.Value)
	label3.text = item_t_t.ItemName + "\n Price : " + str(item_t_t.Value)

func _physics_process(delta: float) -> void:
	pass
