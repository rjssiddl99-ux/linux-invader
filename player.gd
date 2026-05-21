extends CharacterBody2D

@export var speed = 400
@export var health = 5
@export var max_health = 5 # 최대 체력 변수를 따로 하나 파두는 게 좋습니다!
@export var bullet_scene : PackedScene = preload("res://Bullet.tscn")

# 하트 이미지 미리 불러오기 (본인의 실제 파일 경로로 맞춰주세요)
var heart_full = preload("res://heart_full.png")
var heart_empty = preload("res://heart_empty.png")

@onready var shot_timer = $ShotTimer
@onready var heart_container = %HeartContainer # HBoxContainer 연결

func _ready():
	update_ui()

func update_ui():
	if not heart_container:
		return
		
	# 1. 기존에 생성되어 있던 하트 노드들을 싹 지우고 새로 그립니다.
	for child in heart_container.get_children():
		child.queue_free()
	
	# 2. 최대 체력만큼 하트 아이콘(TextureRect)을 새로 생성합니다.
	for i in range(max_health):
		var heart = TextureRect.new()
		
		# 현재 인덱스(i)가 남은 체력(health)보다 작으면 빨간 하트, 크거나 같으면 검은 하트
		if i < health:
			heart.texture = heart_full
		else:
			heart.texture = heart_empty
			
		# 하트 크기가 너무 크다면 코드나 에디터에서 조절 가능합니다.
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.custom_minimum_size = Vector2(50, 50) # 하트 한 개 크기 (원하는 대로 조절)
		
		heart_container.add_child(heart)

func _physics_process(_delta):
	var direction = Input.get_axis("up", "down")
	velocity.y = direction * speed
	move_and_slide()
	global_position.y = clamp(global_position.y, 40, 530)
	if Input.is_action_just_pressed("shot") and shot_timer.is_stopped():
		shoot()

func shoot():
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	shot_timer.start()

func take_damage(amount):
	# 체력이 0 미만으로 내려가지 않도록 방지
	health = max(0, health - amount)
	print("플레이어 체력: ", health)
	
	update_ui() # 하트 상태 갱신
		
	if health <= 0:
		die()

func die():
	print("게임 오버!")
	get_tree().call_deferred("reload_current_scene")
