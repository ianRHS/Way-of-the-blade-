extends CanvasLayer

@onready var score_label: Label = $Label

func _process(_delta: float) -> void:
	score_label.text = "P1: " + str(Global.p1_score) + " | P2: " + str(Global.p2_score)
