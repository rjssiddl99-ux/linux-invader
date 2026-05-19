extends Node2D

# 1. 단일 변수 대신 여러 적을 담을 수 있는 배열로 변경
@export var enemy_scenes: Array[PackedScene] = []
@export var max_enemies: int = 15

var spawn_lanes = [57, 171, 285, 399, 513]
var spawn_x = 1250 

func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0
	timer.timeout.connect(_spawn_enemy)
	timer.start()

func _spawn_enemy():
	# 안전장치: 등록된 적 씬이 하나도 없으면 함수 종료
	if enemy_scenes.is_empty():
		return
		
	var current_enemy_count = get_tree().get_nodes_in_group("enemy").size()
	
	if current_enemy_count < max_enemies:
		# 2. 배열에 들어있는 적들 중 하나를 랜덤하게 선택
		var random_scene = enemy_scenes.pick_random()
		var enemy = random_scene.instantiate()
		
		enemy.add_to_group("enemy")
		
		# 위치 설정
		var random_lane = spawn_lanes[randi() % spawn_lanes.size()]
		enemy.global_position = Vector2(spawn_x, random_lane)
		enemy.stop_x_position = randf_range(700, 950) 
		
		get_tree().current_scene.add_child(enemy)
	else:
		print("적 소환 제한 도달 (현재: ", current_enemy_count, ")")
