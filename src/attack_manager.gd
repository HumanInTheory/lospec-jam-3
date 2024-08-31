extends Node2D

signal attack_complete
signal victim_died
signal actor_died

@onready var background := $background
@onready var left_character := $left_character
@onready var right_character := $right_character
@onready var attack_ui := $"attack-ui"


func _on_battle_manager_initiate_attack(actor: Unit, victim: Unit, terrain: int) -> void:
	show()
	change_backdrop(terrain)
	
	attack_ui.set_left_data_from_unit(actor, victim, terrain)
	attack_ui.set_right_data_from_unit(victim, actor, terrain)
	
	left_character.sprite_frames = actor.attack_frames
	right_character.sprite_frames = victim.attack_frames
	
	left_character.animation = UnitWeapon.Weapon_Type.keys()[actor.weapon.type]
	right_character.animation = UnitWeapon.Weapon_Type.keys()[victim.weapon.type]
	
	actor_hit_attempt(actor, victim)
	await(left_character.animation_finished)
	attack_ui.set_right_health_from_unit(victim)
	await get_tree().create_timer(0.5).timeout
	if victim.health == 0:
		hide()
		victim_died.emit()
		return
	
	victim_hit_attempt(actor, victim)
	await(right_character.animation_finished)
	attack_ui.set_left_health_from_unit(actor)
	await get_tree().create_timer(0.5).timeout
	if actor.health == 0:
		hide()
		actor_died.emit()
		return
	
	if actor.double_attack_against(victim):
		actor_hit_attempt(actor, victim)
		await(left_character.animation_finished)
		attack_ui.set_right_health_from_unit(victim)
		await get_tree().create_timer(0.5).timeout
		if victim.health == 0:
			hide()
			victim_died.emit()
			return
	elif victim.double_attack_against(actor):
		victim_hit_attempt(actor, victim)
		await(right_character.animation_finished)
		attack_ui.set_left_health_from_unit(actor)
		await get_tree().create_timer(0.5).timeout
		if actor.health == 0:
			hide()
			actor_died.emit()
			return
	
	await get_tree().create_timer(0.5).timeout
	hide()
	attack_complete.emit()


func actor_hit_attempt(actor: Unit, victim: Unit) -> void:
	if actor.successful_hit():
		if actor.does_crit():
			left_character.play(left_character.animation + "Crit")
			victim.take_damage(actor.get_attack_power(false, true))
		else:
			left_character.play()
			victim.take_damage(actor.get_attack_power(false, false))


func victim_hit_attempt(actor: Unit, victim: Unit) -> void:
	if victim.successful_hit():
		if victim.does_crit():
			right_character.play(right_character.animation + "Crit")
			actor.take_damage(victim.get_attack_power(false, true))
		else:
			right_character.play()
			actor.take_damage(victim.get_attack_power(false, false))


func change_backdrop(terrain: int) -> void:
	match terrain:
		Level.Cell_Type.Grass:
			background.play("grass")
