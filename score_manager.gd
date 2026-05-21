extends Node

var score : int = 0
var score_label : Label = null

func add_score(amount : int):
	score += amount
	update_ui()

func update_ui():
	if score_label != null:
		score_label.text = "SCORE : " + str(score)

# ─── 여기부터 새로 추가할 코드 ───

## 점수를 출력하고 0점으로 리셋하는 함수
func reset_score():
	# 1. 고도 엔진 터미널(Output 창)에 최종 스코어 출력
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("🎮 GAME OVER - 최종 스코어: ", score)
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	
	# 2. 점수 0으로 초기화 및 UI 업데이트
	score = 0
	update_ui()
