extends TextureProgress

func update_hp(new_hp, max_hp) -> void:
	value = (new_hp / max_hp) * max_value

func _on_Character_hp_changed(new_hp, max_hp) -> void:
	update_hp(new_hp, max_hp)
