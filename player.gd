extends CharacterBody2D

@onready var theWorld = $".."
@onready var playerSprite = $Sprite2D
@onready var hammer01 = load("res://hammer01.tscn")
@onready var hammerClaw = load("res://hammer_claw.tscn")
@onready var hammerMallet = load("res://hammer_mallet.tscn")

signal inventory_changed

var playerSpeed = 4000.0
var playerSprintMult = 1.5
var playerCanAttack = true
var playerAttackCooldown = 0.0
var playerAttackCooldownMax = 0.5
var playerThrowForce = 1000.0

enum HAMMER_TYPE { HAMMER, CLAW, MALLET, SLEDGE, JACKHAMMER, EMPTY }

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var inventory = []
var activeItem = HAMMER_TYPE.EMPTY
var activeItemIndex = 0


func _tickCooldowns(_delta):
	if playerAttackCooldown > 0.0:
		playerAttackCooldown -= _delta
		if playerAttackCooldown <= 0.0:
			playerCanAttack = true

func _addHammer(item):
	inventory.push_back(item)
	if inventory.size() == 1:
		activeItem = item
	inventory_changed.emit()

func _getItemActive():
	if inventory.size() > 0:
		return inventory[activeItemIndex]

func _getItemLeft():
	var i = activeItemIndex - 1
	if i < 0:
		return inventory[inventory.size() - 1]
	return inventory[i]

func _getItemRight():
	var i = activeItemIndex + 1
	if i >= inventory.size():
		return inventory[0]
	return inventory[i]

func _swapItemLeft():
	activeItemIndex -= 1
	if activeItemIndex < 0:
		activeItemIndex = inventory.size() - 1
	inventory_changed.emit()

func _swapItemRight():
	activeItemIndex += 1
	if activeItemIndex >= inventory.size():
		activeItemIndex = 0
	inventory_changed.emit()

func _attackWithHammer(attack_dir):
	pass #TODO: implement normal attack

func _throwHammer(throw_dir):
	playerAttackCooldown = playerAttackCooldownMax
	var throw
	match _getItemActive():
		HAMMER_TYPE.HAMMER:
			throw = hammer01.instantiate()
		HAMMER_TYPE.CLAW:
			throw = hammerClaw.instantiate()
		HAMMER_TYPE.MALLET:
			throw = hammerMallet.instantiate()
	theWorld.add_child(throw)
	
	var clearance = 50.0
	throw.position = (self.position + throw_dir * clearance)
	throw.apply_central_impulse((throw.position - self.position).normalized() * playerThrowForce)
	throw.apply_torque_impulse(1000.0)
	
	inventory.remove_at(activeItemIndex)
	if activeItemIndex >= inventory.size():
		activeItemIndex = 0
	
	inventory_changed.emit()
	playerCanAttack = false
	playerAttackCooldown = playerAttackCooldownMax
	


func _physics_process(delta):
	var moveDir = Vector2(0.0, 0.0)
	var drag = $"..".dragBase

	#if Input.is_action_just_pressed("zoom_in"):
		#_zoomIn()
	#if Input.is_action_just_pressed("zoom_out"):
		#_zoomOut()
	
	if Input.is_action_just_pressed("swap_left") and playerCanAttack and inventory.size() > 1:
		_swapItemLeft()
	if Input.is_action_just_pressed("swap_right") and playerCanAttack and inventory.size() > 1:
		_swapItemRight()
	if Input.is_action_just_released("attack_down") and playerCanAttack and inventory.size() > 0:
		var attackDir = Vector2(0.0, 1.0)
		if Input.is_action_pressed("attack_left"):
			attackDir = Vector2(-1.0, 1.0).normalized()
		elif Input.is_action_pressed("attack_right"):
			attackDir = Vector2(1.0, 1.0).normalized()
		if Input.is_action_pressed("throw"):
			_throwHammer(attackDir)
		else:
			_attackWithHammer(attackDir)
	if Input.is_action_just_released("attack_left") and playerCanAttack and inventory.size() > 0:
		var attackDir = Vector2(-1.0, 0.0)
		if Input.is_action_pressed("attack_up"):
			attackDir = Vector2(-1.0, -1.0).normalized()
		elif Input.is_action_pressed("attack_down"):
			attackDir = Vector2(-1.0, 1.0).normalized()
		if Input.is_action_pressed("throw"):
			_throwHammer(attackDir)
		else:
			_attackWithHammer(attackDir)
	if Input.is_action_just_released("attack_right") and playerCanAttack and inventory.size() > 0:
		var attackDir = Vector2(1.0, 0.0)
		if Input.is_action_pressed("attack_up"):
			attackDir = Vector2(1.0, -1.0).normalized()
		elif Input.is_action_pressed("attack_down"):
			attackDir = Vector2(1.0, 1.0).normalized()
		if Input.is_action_pressed("throw"):
			_throwHammer(attackDir)
		else:
			_attackWithHammer(attackDir)
	if Input.is_action_just_released("attack_up") and playerCanAttack and inventory.size() > 0:
		var attackDir = Vector2(0.0, -1.0)
		if Input.is_action_pressed("attack_left"):
			attackDir = Vector2(-1.0, -1.0).normalized()
		elif Input.is_action_pressed("attack_right"):
			attackDir = Vector2(1.0, -1.0).normalized()
		if Input.is_action_pressed("throw"):
			_throwHammer(attackDir)
		else:
			_attackWithHammer(attackDir)
			
	if Input.is_action_pressed("move_up"):
		moveDir.y = -1.0
	if Input.is_action_pressed("move_down"):
		moveDir.y = 1.0
	if Input.is_action_pressed("move_left"):
		moveDir.x = -1.0
	if Input.is_action_pressed("move_right"):
		moveDir.x = 1.0

	var moveActual = Vector2(moveDir.x, moveDir.y).normalized()
	
	moveActual.x *= playerSpeed * delta
	moveActual.y *= playerSpeed * delta
	
	velocity.x = velocity.x * (1.0 - drag) + moveActual.x
	velocity.y = velocity.y * (1.0 - drag) + moveActual.y
	
	move_and_slide()
	
	_tickCooldowns(delta)
