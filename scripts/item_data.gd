class_name ItemData
extends Resource

enum Type { WEAPON, HELMET, ARMOR, RING, AMULET, GLOVES, BOOTS, BELT, MISC }

@export var item_name: String = "Предмет"
@export var icon: Texture2D 
@export var item_type: Type = Type.MISC 
