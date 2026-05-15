extends CharacterBody2D

@export var health: int = 2 
@export var speed: float = 150.0      # 처음 진입 속도 
@export var dash_speed: float = 600.0 # 돌진 시 속도 
@export var stop_x_position: float = 900.0 

enum State { APPROACH, WAIT, DASH } # 적의 상태 정의 
var current_state = State.APPROACH 

func _ready():
	# 돌진 전 대기할 시간을 정하는 타이머 
	$DashTimer.wait_time = 1.5 
	$DashTimer.one_shot = true 

func _physics_process(_delta):
	match current_state:
		State.APPROACH:
			# 지정된 위치까지 왼쪽으로 이동 
			velocity = Vector2.LEFT * speed
			move_and_slide()
			if global_position.x <= stop_x_position:
				velocity = Vector2.ZERO
				current_state = State.WAIT
				$DashTimer.start() # 멈추면 타이머 시작 
				
		State.WAIT:
			# 타이머가 돌아가는 동안은 가만히 있음 
			pass
			
		State.DASH:
			# 매우 빠른 속도로 왼쪽으로 돌진 
			velocity = Vector2.LEFT * dash_speed
			move_and_slide()
			
			# 맵 밖(왼쪽)으로 완전히 나가면 스스로 삭제 [cite: 4, 5]
			if global_position.x < -100:
				queue_free()

func _on_dash_timer_timeout() -> void:
	current_state = State.DASH 

func _on_hurtbox_area_entered(area: Area2D) -> void:
	# 플레이어의 총알(Area2D)에 맞았을 때 
	take_damage(1)
	area.queue_free() 

func take_damage(amount: int):
	health -= amount 
	print("적 체력: ", health) 
	if health <= 0:
		die() 

func die():
	queue_free() 

func _on_hitbox_body_entered(body: Node2D) -> void:
	# 플레이어 몸체(CharacterBody2D)와 충돌했을 때 
	if body.is_in_group("player"):
		print("플레이어가 돌진하는 적에게 맞음!")
		# 플레이어의 대미지 함수 호출 
		if body.has_method("take_damage"):
			body.take_damage(1)
