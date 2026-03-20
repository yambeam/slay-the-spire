# 记得free
extends Object
class_name Modifier
var type: Enums.NumericType
var additive: int = 0
var multipiler: float = 1.0
# 自定义modifier函数
var function: Variant

func _init(type_: Enums.NumericType, additive_: int, multiplier_: float, function_: Variant) -> void:
	type = type_
	additive = additive_
	multipiler = multiplier_
	function = function_
