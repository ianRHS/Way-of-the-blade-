extends Node

var p1_score: int = 0
var p2_score: int = 0
const WINS_NEEDED: int = 3

func record_defeat(defeated_player: String) -> void:
	if defeated_player == "p1":
		p2_score += 1
	else:
		p1_score += 1
		
		
func is_match_over() -> bool:
	return p1_score >= WINS_NEEDED or p2_score >= WINS_NEEDED
	
func reset_match() -> void:
	p1_score = 0
	p2_score = 0
	
