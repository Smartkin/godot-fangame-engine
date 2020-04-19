class_name WaterBase
extends Node2D

enum TYPE {
	WATER_1,
	WATER_2,
	WATER_3,
}

export var fall_speed := 100
export(TYPE) var type = TYPE.WATER_2
