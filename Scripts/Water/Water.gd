extends Node2D

class_name WaterBase

enum TYPE {
	Water1,
	Water2,
	Water3
}

export var fallSpeed := 100
export(TYPE) var type = TYPE.Water2
