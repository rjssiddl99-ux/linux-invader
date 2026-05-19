extends Area2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 300.0

func _physics_process(delta):
	# 매 프레임마다 설정된 방향으로 이동 
	position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free() # 화면 밖으로 나가면 삭제
	
func _on_body_entered(body: Node2D) -> void:
	# 닿은 대상이 플레이어 그룹인지 확인 
	if body.is_in_group("player"):
		print("플레이어가 적의 총알에 맞음!")
		
		# 플레이어의 대미지 함수를 호출 
		if body.has_method("take_damage"):
			body.take_damage(1)
		
		# 총알은 할 일을 다했으니 사라짐 
		queue_free()
