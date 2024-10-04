extends RigidBody2D

@onready var player = $"../player"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_contact_monitor(true)
	set_max_contacts_reported(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.get_colliding_bodies().size() > 0:
		self.set_linear_damp(0.5)


func _on_pickup_body_entered(body):
	if self.get_linear_velocity().length() < 150.0:
		if body == player:
			player._addHammer(player.HAMMER_TYPE.MALLET)
			queue_free()
