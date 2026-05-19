extends CharacterBody2D

@export var health: int = 3
@export var speed: float = 200.0 # 전진 속도
@export var bullet_scene: PackedScene
@export var stop_x_position: float = 950.0 # 적이 멈출 X 좌표 (1156px 기준 오른쪽 끝 근처)

var is_stopped: bool = false # 정지 상태 확인용 변수

func _ready():
	$AttackTimer.stop()

func _physics_process(_delta):
	# 아직 멈추지 않았다면 왼쪽으로 이동
	if not is_stopped:
		velocity = Vector2.LEFT * speed
		move_and_slide()
		
		# 설정한 X 좌표보다 왼쪽으로 들어오면 정지
		if global_position.x <= stop_x_position:
			is_stopped = true
			velocity = Vector2.ZERO # 속도를 0으로
			$AttackTimer.start() # 정지함과 동시에 사격 시작

# 총알을 생성하고 정면(왼쪽)으로 발사하는 함수
func shoot():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		
		bullet.global_position = global_position
		# 플레이어 위치와 상관없이 무조건 왼쪽(Vector2.LEFT)으로 발사
		bullet.direction = Vector2.LEFT

func _on_attack_timer_timeout() -> void:
	shoot()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	take_damage(1)
	area.queue_free() 

func take_damage(amount: int):
	health -= amount
	print("적 체력: ", health)
	if health <= 0:
		die()

func die():
	var main = get_tree().current_scene

	main.add_score(100)

	queue_free()
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("플레이어와 충돌!")
