extends CanvasLayer

@onready var player = $"../player"
@onready var spriteActive = $item_active
@onready var spriteLeft = $item_left
@onready var spriteRight = $item_right

var blank := preload("res://sprites/blank.png")
var noHammer := preload("res://sprites/no_hammer.png")
var hammer01 := preload("res://sprites/hammer01.png")
var hammer_claw := preload("res://sprites/hammer_claw.png")
var hammer_mallet := preload("res://sprites/hammer_mallet.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_inventory_changed():
	if player.inventory.size() > 0:
		match player._getItemActive():
			player.HAMMER_TYPE.HAMMER:
				spriteActive.set_texture(hammer01)
			player.HAMMER_TYPE.CLAW:
				spriteActive.set_texture(hammer_claw)
			player.HAMMER_TYPE.MALLET:
				spriteActive.set_texture(hammer_mallet)
		
		match player._getItemLeft():
			player.HAMMER_TYPE.HAMMER:
				spriteLeft.set_texture(hammer01)
			player.HAMMER_TYPE.CLAW:
				spriteLeft.set_texture(hammer_claw)
			player.HAMMER_TYPE.MALLET:
				spriteLeft.set_texture(hammer_mallet)
		
		match player._getItemRight():
			player.HAMMER_TYPE.HAMMER:
				spriteRight.set_texture(hammer01)
			player.HAMMER_TYPE.CLAW:
				spriteRight.set_texture(hammer_claw)
			player.HAMMER_TYPE.MALLET:
				spriteRight.set_texture(hammer_mallet)
	else:
		spriteActive.set_texture(noHammer)
		spriteLeft.set_texture(blank)
		spriteRight.set_texture(blank)
