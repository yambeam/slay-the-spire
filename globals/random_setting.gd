extends Node

var instance:RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Initialize()

func Initialize()->void:
	instance=RandomNumberGenerator.new()
	instance.randomize()

func set_from_save_data(whichseed:int,state:int)->void:
	instance=RandomNumberGenerator.new()
	instance.seed=whichseed
	instance.state=state
	
func array_pick_random(array:Array)->Variant:
	return array[instance.randi()%array.size()]
	
func array_shuffle(array:Array)->void:
	if array.size()<2:
		return
	for i in range(array.size()-1,0,-1):
		var j:=instance.randi()%(i+1)
		var temp=array[j]
		array[j]=array[i]
		array[i]=temp
		
