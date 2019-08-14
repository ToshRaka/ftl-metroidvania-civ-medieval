extends KinematicBody2D
class_name Character

onready var HPBar := $MarginContainer/HPBar
onready var AnimationPlayer := $AnimationPlayer

const Y_AXIS := Vector2(0,1)
const VERTICAL_ANIMATION_ANGLE : float = 0.3

signal died
signal hp_changed
signal hp_low
signal navigation_changed
signal quit_flock

enum State {IDLE, MOVE_TO_TARGET, FIGHT, CHASING_LOCKED, CHASING_UNLOCKED, FLEE, RETREAT, DEAD}
var state : int = State.IDLE
var fight_enemy : Character = null
var chase_enemy : Character = null
var chase_lock : float # seconds before chasing gets unlocked

class CoreStats:
	var sight_range : float = 100.0
	
class WeaponStats:
	var attack_range : float = 24.0
	var attack_amount : float = 20.0
	var hits_per_second : float = 1.0

class FighterStats:
	var team_id : int = 0
	
	var max_hp : float = 200.0
	var hp : float = max_hp setget set_hp
	
	func set_hp(value : float) -> void:
		hp = value
		if hp <= 0.0:
			hp = 0.0

var char_name : String = "Gaston" setget set_charname
var core_stats : CoreStats = CoreStats.new()
var stats : FighterStats = FighterStats.new()
var weapon : WeaponStats = WeaponStats.new()
var enemies : Array setget set_enemies
var next_hit : float = 0

var speed : float = 100
var path := PoolVector2Array() setget set_path
var flock : Object setget set_flock
var previous_velocity : Vector2 = Vector2()

enum WalkAnim {UP, DOWN, LEFT, RIGHT}
var last_anims : Array = Array()

func _ready() -> void:
	for i in range(16):
		last_anims.push_back(WalkAnim.DOWN)

	HPBar.update_hp(stats.hp, stats.max_hp)

func get_anim() -> int:
	var tmp := [0, 0, 0, 0]
	for anim in last_anims:
		tmp[anim] += 1
	var id_max : int = 0
	var count_max : int = tmp[0]
	for i in range(1, len(tmp)):
		if tmp[i] > count_max:
			count_max = tmp[i]
			id_max = i
	return id_max

func _process(delta : float) -> void:
	ia_process(delta)
		
func is_enemy_in_range(enemy : Character, r : float) -> bool:
	var d : Vector2 = enemy.global_position - global_position
	return d.length_squared() <= r * r

# Returns the "first" (not the closest) enemy Character within range
func enemy_in_range(r : float) -> Character:
	for enemy in enemies:
		# TODO: remove enemy from enemies if enmy.state == State.DEAD
		if enemy.state != State.DEAD and is_enemy_in_range(enemy, r):
			return enemy
	return null
	
func state_attack_enemy(enemy : Character) -> void:
	if state == State.IDLE \
	or state == State.MOVE_TO_TARGET \
	or state == State.CHASING_LOCKED \
	or state == State.CHASING_UNLOCKED:
		fight_enemy = enemy
		state = State.FIGHT
	
func state_move_to_target(p : PoolVector2Array) -> void:
	if state == State.IDLE \
	or state == State.MOVE_TO_TARGET \
	or state == State.FIGHT \
	or state == State.CHASING_LOCKED \
	or state == State.CHASING_UNLOCKED:
		var tmp := PoolVector2Array()
		tmp.append_array(p)
		path = tmp
		state = State.MOVE_TO_TARGET

func state_stop_move_to_target() -> void:
	if state == State.MOVE_TO_TARGET:
		state = State.IDLE
		
func state_chase(enemy : Character) -> void:
	if state == State.IDLE \
	or state == State.FIGHT:
		chase_enemy = enemy
		chase_lock = 1.0
		emit_signal("navigation_changed", self, enemy.global_position, [self])
		state = State.CHASING_LOCKED
	
func ia_process(delta : float) -> void:
	match state:
		State.IDLE:
			var to_attack : Character = enemy_in_range(weapon.attack_range)
			if to_attack:
				state_attack_enemy(to_attack)
			else:
				var to_chase : Character = enemy_in_range(core_stats.sight_range)
				if to_chase:
					state_chase(to_chase)
		State.MOVE_TO_TARGET:
			move_along_path(delta)
		State.FIGHT:
			if fight_enemy.state == State.DEAD:
				state = State.IDLE
			elif not is_enemy_in_range(fight_enemy, weapon.attack_range):
				state_chase(fight_enemy)
				fight_enemy = null
			else:
				fight(delta)
		State.CHASING_LOCKED:
			if chase_enemy.state == State.DEAD:
				state = State.IDLE
			else:
				var to_attack : Character = enemy_in_range(weapon.attack_range)
				if to_attack:
					state_attack_enemy(to_attack)
				else:
					chase_lock -= delta
					if chase_lock <= 0.0:
						state = State.CHASING_UNLOCKED
		
					move_along_path(delta)
		State.CHASING_UNLOCKED:
			if chase_enemy.state == State.DEAD:
				state = State.IDLE
			else:
				var to_attack : Character = enemy_in_range(weapon.attack_range)
				if to_attack:
					state_attack_enemy(to_attack)
				else:
					move_along_path(delta)
		State.FLEE:
			pass
		State.RETREAT:
			pass
		State.DEAD:
			pass

func fight(delta : float) -> void:
	if state != State.FIGHT:
		return
	if next_hit > 0.0:
		next_hit -= delta

	if next_hit <= 0.0:
		fight_enemy.take_damage(weapon.attack_amount)
		next_hit = 1.0 / weapon.hits_per_second

func reach_delta(rel : Vector2) -> bool:
	# Try to go to the specified target
	# If there's a collision in between, find a way around
	# Way around = slide along the collision tangent
	
	var collision : KinematicCollision2D = move_and_collide(rel, false)
	if collision:
		var tangent : Vector2 = collision.normal.tangent().normalized()
		var new_rel : Vector2 = (rel.length()-collision.travel.length()) * tangent
		
		play_move_animation(new_rel)
		var collision1 : KinematicCollision2D = move_and_collide(new_rel)
		if collision1:
			previous_velocity = collision.travel + collision1.travel
		else:
			previous_velocity = collision.travel
		return false
	previous_velocity = rel
	play_move_animation(rel)
	return true
	
func move_along_path(delta : float) -> void:
	if not path or path.size() == 0:
		AnimationPlayer.play("Idle")
		state_stop_move_to_target()
		return
	
	var distance : float = speed * delta
	
	var to_target : Vector2 = (path[0] - position).normalized()
	var to_away : Vector2 = flock.away_from_others(self)
	var to_cohesion : Vector2 = flock.cohesion(self)
	var d : Vector2 = .6 * to_target + .2 * to_away + .2 * to_cohesion

	var required_rel : Vector2 = d * distance
	var filtered_rel : Vector2 = .8 * required_rel + .2 * previous_velocity
	
	reach_delta(filtered_rel)

	var is_close : bool = (global_position-path[0]).length_squared() < flock.size()*(32*32)
	if path.size() > 1:
		if is_close:
			path.remove(0)
	else:
		if is_close and flock.dispersion() < 32 and (flock.centrum()-path[0]).length_squared() < 32*flock.size():
			path.remove(0)

func play_move_animation(speed_vector: Vector2) -> void:
	var anim : int = WalkAnim.DOWN
	if speed_vector.normalized().abs().dot(Y_AXIS) > .7:
		if speed_vector.y > 0:
			pass
		else:
			anim = WalkAnim.UP
	else:
		if speed_vector.x > 0:
			anim = WalkAnim.RIGHT
		else:
			anim = WalkAnim.LEFT
	
	last_anims.pop_front()
	last_anims.push_back(anim)
	
	match get_anim():
		WalkAnim.UP:
			AnimationPlayer.play("Up")
		WalkAnim.DOWN:
			AnimationPlayer.play("Down")
		WalkAnim.LEFT:
			AnimationPlayer.play("Left")
		WalkAnim.RIGHT:
			AnimationPlayer.play("Right")

func set_path(value : PoolVector2Array) -> void:
	path = value

func set_charname(value : String) -> void:
	# Small reminder to implement a name generator :)
	char_name = value
	
func set_enemies(value : Array) -> void:
	enemies = value
	
func set_flock(value : Object) -> void:
	flock = value
	
func take_damage(damage : float) -> void:
	stats.set_hp(stats.hp - damage)
	if stats.hp <= 0.0:
		emit_signal("died", self)
	elif stats.hp <= 5 * stats.max_hp / 100:
		emit_signal("hp_low")
	emit_signal("hp_changed", stats.hp, stats.max_hp)

func _unhandled_key_input(event: InputEventKey) -> void:
	# For HP bar testing
	if event.is_action_released("ui_page_down"):
		take_damage(5*stats.max_hp/100)

func _on_Character_died(c : Character):
	state = State.DEAD

func _on_Character_hp_low():
	state = State.FLEE
