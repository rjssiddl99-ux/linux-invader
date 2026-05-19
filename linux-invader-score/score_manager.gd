extends Node2D

var score : int = 0

@onready var score_label = $CanvasLayer/ScoreLabel

func _ready():
	update_ui()
	
func add_score(amount : int):
	score += amount
	update_ui()

func update_ui():
	score_label.text = "SCORE : " + str(score)
