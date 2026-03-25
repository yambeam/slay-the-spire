class_name RunStartup
extends Resource

enum Type {NEW_RUN, CONTINUE_RUN}

@export var type: Type
@export var picked_character: CharacterStats
