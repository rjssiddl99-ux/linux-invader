extends Node2D

# 1. 단일 변수 대신 여러 적을 담을 수 있는 배열로 변경
@export var enemy_scenes: Array[PackedScene] = []
@export var max_enemies: int = 15

var spawn_lanes = [57, 171, 285, 399, 513]
var spawn_x = 1250 

# 게임이 시작된 후 흘러간 시간을 저장한 변수
var time_elapsed: float = 0.0

func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0
	timer.timeout.connect(_spawn_enemy)
	timer.start()

func _process(delta):
	# 매 프레임마다 시간을 누적하여 측정합니다.
	time_elapsed += delta
	
func _spawn_enemy():
	# 안전장치: 등록된 적 씬이 하나도 없으면 함수 종료
	if enemy_scenes.is_empty():
		return
		
	var current_enemy_count = get_tree().get_nodes_in_group("enemy").size()
	
	if current_enemy_count < max_enemies:
		# 1. 이번 소환에 사용할 '적 번호 뽑기 주머니' 생성
		var spawn_pool: Array[int] = []
		
		# 2. 시간에 따라 웨이브 분기 및 스폰율(확률) 설정
		if time_elapsed < 30.0:
			# [웨이브 1] 0초 ~ 30초: 기본형과 산탄형만 등장
			# 주머니에 0번을 3개, 1번을 1개 넣음 -> 기본형 75%, 산탄형 25% 확률
			spawn_pool = [0, 0, 0, 1]
		else:
			# [웨이브 2] 30초 이후: 산탄형, 돌진형, 저격형 등장 (기본형 퇴장)
			# 주머니 비율 조절 -> 산탄형 40%(2개), 돌진형 40%(2개), 저격형 20%(1개)
			spawn_pool = [1, 1, 2, 2, 3]
			
		# 3. 주머니에서 무작위로 인덱스 하나를 뽑음
		var random_index = spawn_pool.pick_random()
		
		# 안전장치: 혹시 인스펙터에 적을 덜 등록했을 때 터지는 것 방지
		if random_index >= enemy_scenes.size():
			return
			
		var enemy = enemy_scenes[random_index].instantiate()
		enemy.add_to_group("enemy")
		
		# 위치 설정
		var random_lane = spawn_lanes[randi() % spawn_lanes.size()]
		enemy.global_position = Vector2(spawn_x, random_lane)
		enemy.stop_x_position = randf_range(700, 950) 
		
		get_tree().current_scene.add_child(enemy)
	else:
		print("적 소환 제한 도달 (현재: ", current_enemy_count, ")")
