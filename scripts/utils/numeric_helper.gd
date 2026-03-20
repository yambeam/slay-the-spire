class_name NumericHelper

static func apply_modifers(base: int, modifiers: Array) -> int:
	var total_additive := 0
	var total_multiplier := 1.0
	var total_callables := []
	for modifier: Modifier in modifiers:
		total_additive += modifier.additive
		total_multiplier *= modifier.multipiler
		if modifier.function:
			total_callables.append(modifier.function)
	var ret = (base + total_additive) * total_multiplier
	for function in total_callables:
		ret = function.call(ret)
	return ret

static func combine_modifiers(source_m: Array, target_m: Array) -> Array:
	# 也许需要排序，但是目前看来基本用不上modifier.function,排序没意义
	return source_m + target_m
		
