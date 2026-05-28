extends Node2D

# 1. 단일 변수 대신 여러 적을 담을 수 있는 배열로 변경
@export var enemy_scenes: Array[PackedScene] = []
@export var max_enemies: int = 15

var spawn_lanes = [57, 171, 285, 399, 513]
var spawn_x = 1250 

# 게임이 시작된 후 흘러간 시간을 저장한 변수
var time_elapsed: float = 0.0

enum SpawnerState { NORMAL, BREAK, DASHWAVE }
var current_state = SpawnerState.NORMAL

# 각 웨이브나 대기 시간이 언제 시작될지 타임라인 정의
var break_start_time: float = 30.0    # 30초에 일반 스폰 중지 및 대기 시작
var special_start_time: float = 40.0  # 40초에 특수 웨이브 시작 (10초간 휴식)
var normal_return_time: float = 55.0   # 55초에 다시 일반 웨이브로 복귀 (15초간 특수 진행)

# --- [수정] 횟수 카운트 변수는 삭제하고, 타이머 변수만 남김 ---
var special_timer: Timer = null
# [변수 선언부] 방화벽 인스턴스를 기억해둘 방 하나 생성
var firewall_instance: Node2D = null

func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0
	timer.timeout.connect(_spawn_enemy)
	timer.start()

func _process(delta):
	# 매 프레임마다 시간을 누적하여 측정합니다.
	time_elapsed += delta
	_check_wave_timeline()
	
func _check_wave_timeline():
	if current_state == SpawnerState.NORMAL and time_elapsed >= break_start_time and time_elapsed < special_start_time:
		current_state = SpawnerState.BREAK
		print("=== 일반 스폰 중지! 잠깐의 휴식 및 대기 시간 ===")
		
	elif current_state == SpawnerState.BREAK and time_elapsed >= special_start_time and time_elapsed < normal_return_time:
		current_state = SpawnerState.DASHWAVE
		print("=== [⚠️특수 웨이브] 돌진형 적 폭주! ===")
		
		# 🌟 [수정] 특수 웨이브 시작할 때 방화벽도 같이 소환!
		_spawn_firewall_wall()
		
		# 특수 웨이브 시작 시 반복 타이머를 켭니다.
		_start_special_wave_timer()
		
	# [중요] 타임라인 시간이 다 되어 DASHWAVE 상태가 끝나는 순간!
	elif current_state == SpawnerState.DASHWAVE and time_elapsed >= normal_return_time:
		current_state = SpawnerState.NORMAL
		print("=== 특수 웨이브 종료. 다시 일반 적들 배치 ===")
		
		# 🌟 [수정] 특수 웨이브 끝나면 타이머 끄고 방화벽도 퇴근시키기!
		if special_timer and is_instance_valid(special_timer):
			special_timer.queue_free()
		_clear_firewalls()
		
		# 특수 타이머가 아직 살아있다면 여기서 확실하게 파괴하여 스폰을 중지시킵니다.
		if special_timer and is_instance_valid(special_timer):
			special_timer.queue_free()

# --- [수정] 횟수 제한(7번) 조건문을 완전히 제거한 타이머 함수 ---
func _start_special_wave_timer():
	special_timer = Timer.new()
	add_child(special_timer)
	special_timer.wait_time = 2.0 # 2초 간격으로 5마리씩 지속 시간 동안 '무한' 스폰!
	special_timer.timeout.connect(func():
		# 만약 어떤 이유로든 상태가 DASHWAVE가 아니게 되었다면 안전하게 타이머 종료
		if current_state != SpawnerState.DASHWAVE:
			special_timer.queue_free()
			return
			
		_spawn_5_lanes_dash()
		print("특수 웨이브 지속 중... 5개 라인 동시 스폰!")
	)
	special_timer.start()
	
	# 타이머가 가동되자마자 첫 번째 웨이브는 딜레이 없이 즉시 뿜어줍니다.
	_spawn_5_lanes_dash()

# --- 실제로 5개 라인에 돌진형 적을 배치하는 함수 (동일) ---
func _spawn_5_lanes_dash():
	if enemy_scenes.size() < 3: return
	var dash_scene = enemy_scenes[2]
	
	var current_enemy_count = get_tree().get_nodes_in_group("enemy").size()
	if current_enemy_count + 5 > max_enemies: return

	for lane_y in spawn_lanes:
		var enemy = dash_scene.instantiate()
		enemy.add_to_group("enemy")
		enemy.global_position = Vector2(spawn_x, lane_y)
		enemy.stop_x_position = randf_range(700, 950) 
		get_tree().current_scene.add_child(enemy)

# 🌟 [새로 추가] 무적의 방화벽 배치 함수
func _spawn_firewall_wall():
	if enemy_scenes.size() < 5: 
		print("오류: 인스펙터 4번 칸에 방화벽 씬이 없습니다!")
		return
		
	var firewall_scene = enemy_scenes[4] # 4번 칸에서 방화벽 팩씬 로드
	firewall_instance = firewall_scene.instantiate()
	firewall_instance.add_to_group("enemy")
	firewall_instance.add_to_group("firewall") # 나중에 지우기 쉽게 전용 그룹 지정
	
	# 화면 중간(X: 1250)에서 스폰되어 정착지(X: 650)까지 걸어오도록 세팅
	# Y 좌표는 화면 정중앙인 300 라인 부근에서 시작
	firewall_instance.global_position = Vector2(spawn_x, 300)
	
	get_tree().current_scene.add_child(firewall_instance)

# [새로 추가] 특수 웨이브 종료 시 방화벽 퇴근시키는 함수
func _clear_firewalls():
	var firewalls = get_tree().get_nodes_in_group("firewall")
	for wall in firewalls:
		if is_instance_valid(wall):
			wall.is_retreating = true

func _spawn_enemy():
	if enemy_scenes.is_empty(): return
	if current_state == SpawnerState.BREAK or current_state == SpawnerState.DASHWAVE:
		return
		
	var current_enemy_count = get_tree().get_nodes_in_group("enemy").size()
	if current_enemy_count >= max_enemies: return

	var spawn_pool: Array[int] = []
	match current_state:
		SpawnerState.NORMAL:
			if time_elapsed < 30.0:
				spawn_pool = [0, 0, 0, 1]
			else:
				spawn_pool = [0, 1, 1, 1, 2, 2, 3, 3]
				
	var random_index = spawn_pool.pick_random()
	var enemy = enemy_scenes[random_index].instantiate()
	enemy.add_to_group("enemy")
	
	var random_lane = spawn_lanes[randi() % spawn_lanes.size()]
	enemy.global_position = Vector2(spawn_x, random_lane)
	enemy.stop_x_position = randf_range(700, 950) 
	get_tree().current_scene.add_child(enemy)
