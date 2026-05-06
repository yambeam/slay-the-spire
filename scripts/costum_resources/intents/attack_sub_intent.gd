class_name AttackSubIntent
extends SubIntent

@export var damage_provider: NumericProvider
@export var repeat_provider: NumericProvider

func get_text() -> String:
	var repeat = 1
	if repeat_provider:
		repeat = repeat_provider.get_value()
	if repeat > 1:
		return "{damage}x{repeat}".format({"damage": _get_final_value(damage_provider.get_value(null, {})), "repeat": repeat_provider.get_value(null, {})})
	else:
		return "{damage}".format({"damage": _get_final_value(damage_provider.get_value(null, {}))})
		
func get_intent_description() -> String:
	var repeat = 1
	if repeat_provider:
		repeat = repeat_provider.get_value()
	if repeat > 1:
		return "该敌人将要[color=gold]攻击[/color]造成{0}点伤害{1}次".format([damage_provider.get_value(null, {}), repeat])
	return "该敌人将要[color=gold]攻击[/color]造成{0}点伤害".format([damage_provider.get_value(null, {})])

func _get_final_value(base_value: int) -> int:
		var modifiers : Array = []
		if target:
			modifiers = NumericHelper.combine_modifiers(source.get_modifiers_by_type(Enums.NumericType.DAMAGE, BuffResource.AFFECT.SELF), target.get_modifiers_by_type(Enums.NumericType.DAMAGE, BuffResource.AFFECT.TARGET))
		else:
			modifiers = source.get_modifiers_by_type(Enums.NumericType.DAMAGE, BuffResource.AFFECT.SELF)
		return NumericHelper.apply_modifiers(base_value, modifiers)		

func get_total_damage() -> int:
	var repeat = 1
	var damage: int = _get_final_value(damage_provider.get_value(null, {}))
	if repeat_provider:
		repeat = repeat_provider.get_value(null, {})
	return damage * repeat
