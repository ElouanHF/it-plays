extends Node3D

var sf: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	sf = randf_range(0.5, 1.5)
	self.scale = Vector3(sf, sf, sf)
