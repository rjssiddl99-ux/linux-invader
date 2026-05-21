extends CharacterBody2D

func _ready():
	# 부모(Main)에게서 SpawnPoint라는 이름을 가진 노드를 찾아 그 위치를 내 위치로 설정
	var spawn_node = get_parent().get_node("SpawnPoint")
	if spawn_node:
		global_position = spawn_node.global_position
