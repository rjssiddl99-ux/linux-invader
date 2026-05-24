extends CharacterBody2D

@export var health: int = 3
@export var speed: float = 200.0 # 전진 속도
@export var bullet_scene: PackedScene
@export var stop_x_position: float = 950.0 # 적이 멈출 X 좌표 (1156px 기준 오른쪽 끝 근처)
@export var escape_time: float = 15.0   # 적이 화면에 머무는 시간 (15초 후 도망)
@export var retreat_speed: float = 250.0 # 후퇴할 때 속도 (들어올 때보다 빠르게!)

var is_retreating: bool = false        # 현재 후퇴 중인지 확인하는 플래그

var is_stopped: bool = false # 정지 상태 확인용 변수

func _ready():
	$AttackTimer.stop()
	# [변경/추가] 코드로 도망용 타이머를 생성하고 람다식으로 연결합니다.
	var escape_timer = Timer.new()
	add_child(escape_timer)
	escape_timer.wait_time = escape_time
	escape_timer.one_shot = true
	
	escape_timer.timeout.connect(func():
		is_retreating = true
		# 도망칠 때는 더 이상 총을 쏘지 못하도록 타이머를 멈춥니다.
		if has_node("AttackTimer"):
			$AttackTimer.stop()
			
		# --- [추가] 이미지를 좌우로 뒤집습니다. ---
		# 보통 적 이미지가 왼쪽을 보고 있으므로, flip_h를 true로 하면 오른쪽을 봅니다.
		# 노드 이름이 $Sprite2D가 아니라면 실제 이름으로 맞춰주세요 (예: $AnimatedSprite2D)
		if has_node("Sprite2D"):
			$Sprite2D.flip_h = true
		print("적이 시스템 뒤로 후퇴합니다!")
	)
	escape_timer.start()

func _physics_process(_delta):
	# [추가] 1. 만약 후퇴 상태라면 무조건 오른쪽으로 도망칩니다.
	if is_retreating:
		velocity = Vector2.RIGHT * retreat_speed
		move_and_slide()
		
		# 화면 오른쪽 바깥(예: 1300px)으로 완전히 나가면 적을 트리에서 삭제해 줍니다.
		if global_position.x > 1300:
			queue_free()
		return # 중요: 후퇴 중일 때는 아래의 기존 진입/정지 코드를 실행하지 않고 여기서 끝냅니다.
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
		# 총알 3발의 각도를 정함 (라디안 단위 사용)
		# 정면(180도), 위로 15도, 아래로 15도
		var angles = [deg_to_rad(-15), deg_to_rad(0), deg_to_rad(15)]
		
		for angle in angles:
			var bullet = bullet_scene.instantiate()
			get_tree().current_scene.add_child(bullet)
			
			bullet.global_position = global_position
			
			# Vector2.LEFT(정면 왼쪽)를 기준으로 정해진 각도만큼 회전시킴
			bullet.direction = Vector2.LEFT.rotated(angle)

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
	# 주소창(get_node) 없이 싱글톤 이름으로 바로 점수를 올립니다.
	ScoreManager.add_score(200)
	
	queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("플레이어와 충돌!")
