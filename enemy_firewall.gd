extends CharacterBody2D

@export var health: int = 99
@export var speed: float = 200.0  # 등장할 때와 퇴근할 때 이동 속도

var is_arrived: bool = false      # 목표 중앙 지점에 도착했는지 여부
var is_retreating: bool = false   # 특수 웨이브가 끝나고 퇴근 중인지 여부

@onready var start_y: float = global_position.y
var time_passed: float = 0.0

func _ready():
	# 방화벽은 사격 기능이 없으므로, 기존 타이머가 복제되었다면 안전하게 멈춥니다.
	if has_node("AttackTimer"):
		$AttackTimer.stop()

func _physics_process(delta):
	# [버그 방지 안전장치 1] 후퇴 상태라면 다른 모든 이동/왕복 로직을 즉시 탈출(return)합니다.
	if is_retreating:
		# 🌟 Vector2.RIGHT(오른쪽)으로 후퇴합니다.
		velocity = Vector2.RIGHT * speed
		move_and_slide()
		
		# 🌟 화면 오른쪽 끝(스폰 지점인 1250 너머)으로 완전히 나가면 삭제합니다.
		if global_position.x > 1400:
			queue_free()
		return

	# 상황 2: 맵 오른쪽 끝에서 스폰되어 중앙(X: 650)으로 들어오는 상태
	if not is_arrived:
		velocity = Vector2.LEFT * speed
		move_and_slide()
		
		# 지정한 정착지에 도달하면 정지 신호를 켭니다.
		if global_position.x <= 650.0:
			is_arrived = true
			velocity = Vector2.ZERO
			start_y = global_position.y 
			
	# 상황 3: 중앙 정착 완료! 위아래로만 왕복 운동
	else:
		time_passed += delta
		
		var wave_speed = (2.0 * PI) / 4.0 
		var move_range = 180.0 
		
		# 🌟 X 좌표는 건드리지 않고 오직 Y 좌표만 사인파로 흔들어줍니다.
		global_position.y = start_y + sin(time_passed * wave_speed) * move_range
# 플레이어 총알이 방화벽 훠트박스(Hurtbox)에 부딪혔을 때 실행되는 함수
func _on_hurtbox_area_entered(area: Area2D) -> void:
	take_damage(1)
	# 플레이어의 총알은 통과하지 못하고 파괴됩니다!
	area.queue_free() 

func take_damage(amount: int):
	health -= amount
	print("방화벽 남은 맷집: ", health)
	if health <= 0:
		die()

func die():
	# 혹시라도 핵딜을 넣어서 방화벽을 깼다면 보너스 점수 충전!
	if ScoreManager:
		ScoreManager.add_score(999)
	queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	# 플레이어 몸체와 부딪혔을 때의 처리 (필요시 구현)
	if body.is_in_group("player"):
		print("플레이어가 방화벽에 충돌!")
