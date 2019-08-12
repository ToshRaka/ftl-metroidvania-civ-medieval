extends MarginContainer

onready var nameLabel : Label = $HBoxContainer/VBoxContainer/Label
onready var hpBar : TextureProgress = $HBoxContainer/VBoxContainer/HealthBar

var character

func _ready() -> void:
	if character:
		nameLabel.text = character.char_name
		update_hp(character.hp, character.max_hp)

func set_character(value) -> void:
	character = value
	character.connect("hp_changed", self, "_on_Character_hp_changed")
	update()

func update_hp(new_hp, max_hp) -> void:
	hpBar.max_value = max_hp
	hpBar.value = (new_hp / max_hp) * hpBar.max_value

func _on_Character_hp_changed(new_hp, max_hp) -> void:
	update_hp(new_hp, max_hp)
