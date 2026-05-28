extends Area2D

@export var damage = 1
@export var speed = 800 

func _physics_process(delta):
	# 가로형 게임 기준: 오른쪽으로 이동
	position.x += speed * delta

# 화면 밖으로 나가면 메모리 삭제
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

# ★ 적(CharacterBody2D)과 충돌했을 때 실행
func _on_body_entered(body: Node2D) -> void:
	# 1. 플레이어 본인은 무시 (Player 노드에 'player' 그룹 추가 필요)
	if body.is_in_group("player"):
		return
	
	# 2. 적 스크립트에 'take_damage' 함수가 있는지 확인 (cite 4, 10, 11 참고)
	if body.has_method("take_damage"):
		body.take_damage(damage) # 적의 체력을 깎음 [cite: 4, 10]
		
		# 3. 맞췄으니 총알 삭제 (물리 엔진 안전을 위해 deferred 사용)
		call_deferred("queue_free")
