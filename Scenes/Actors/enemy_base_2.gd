extends CharacterBody2D

@export var speed: float = 80.0
@export var gravity: float = 980.0
@export var damage: int = 10
@export var hp: int = 3

var direction: int = 1 # 1 = ขวา, -1 = ซ้าย

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# 1. คำนวณแรงโน้มถ่วง
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. เปลี่ยนทิศทางเมื่อชนกำแพง
	if is_on_wall():
		direction *= -1

	# 3. กำหนดความเร็วแกน X
	velocity.x = direction * speed

	# 4. พลิกภาพตามทิศทางเดิน
	if direction != 0:
		animated_sprite.flip_h = (direction < 0)

	move_and_slide()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

func take_damage(amount: int) -> void:
	hp -= amount
	print("Enemy โดนโจมตี! HP เหลือ: ", hp)
	
	if hp <= 0:
		die()

func die() -> void:
	queue_free() # ลบศัตรูออกจากฉากเมื่อ HP หมด
