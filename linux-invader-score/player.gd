extends CharacterBody2D

@export var speed = 400
@export var health = 5
@export var bullet_scene : PackedScene = preload("res://Bullet.tscn")

@onready var shot_timer = $ShotTimer
@onready var health_bar = get_parent().get_node("CanvasLayer/HealthBar")
@onready var health_label = get_parent().get_node("CanvasLayer/HealthBar/Label")
func _ready():

	setup_health_bar()
	update_ui()

func setup_health_bar():
	if health_bar:
		health_bar.min_value = 0
		health_bar.max_value = health
		health_bar.value = health
		health_bar.show_percentage = false
		
		# 코드로 빨간색 입히기
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color.RED
		health_bar.add_theme_stylebox_override("fill", sb)

func update_ui():
	if health_bar:
		health_bar.value = health
	if health_label:
		# 현재 체력을 5, 4, 3 처럼 숫자로 표시
		health_label.text = str(health)

func _physics_process(_delta):
	var direction = Input.get_axis("up", "down")
	velocity.y = direction * speed
	move_and_slide()
	
	if Input.is_action_just_pressed("shot") and shot_timer.is_stopped():
		shoot()

func shoot():
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	shot_timer.start()


func take_damage(amount):
	health -= amount
	print("플레이어 체력: ", health)
	
	update_ui()
		
	if health <= 0:
		die()

func die():
	var main = get_tree().current_scene

	print("게임 오버!")
	print("최종 점수: ", main.score)

	get_tree().call_deferred("reload_current_scene")
