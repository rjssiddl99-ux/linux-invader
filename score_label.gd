extends Label

func _ready():
	# 게임이 켜지자마자 싱글톤 매니저에게 '나(self)'를 배달 주소로 등록합니다.
	ScoreManager.score_label = self
	ScoreManager.update_ui()
