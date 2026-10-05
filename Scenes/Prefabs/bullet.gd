extends RigidBody2D

@export var damage: int = 1
@export var knockback_force: float = 250.0 # แรงปะทะที่ผลักศัตรูถอยหลัง

func _ready() -> void:
	# 1. เปิดระบบตรวจจับการชนของ RigidBody2D
	contact_monitor = true
	max_contacts_reported = 4
	
	# 2. เชื่อมต่อ Signal การชนเข้ากับฟังก์ชันทำดาเมจ
	body_entered.connect(_on_body_entered)

func shoot(direction: Vector2, speed: float, lifetime: float) -> void:
	# คำนวณทิศทางและความเร็วให้พุ่งคงที่ตรงตามที่เล็ง
	linear_velocity = direction.normalized() * speed
	
	# ตั้งเวลาลบกระสุนทิ้งอัตโนมัติเมื่อหมดระยะเวลา
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _on_body_entered(body: Node) -> void:
	var target = body
	
	# หากกระสุนชนโดน Area2D (Hitbox) ให้ถอยขึ้นไปหาโหนดแม่ (CharacterBody2D)
	if body is Area2D:
		target = body.get_parent()
		
	# ตรวจสอบกลุ่ม Enemy และสั่งทำดาเมจ
	if target.is_in_group("Enemy"):
		# 1. ทำดาเมจใส่ศัตรู
		if target.has_method("take_damage"):
			target.take_damage(damage)
			
		# 2. ผลักศัตรูถอยหลัง (Knockback) ตามทิศทางพุ่งของกระสุน
		if target is CharacterBody2D and "velocity" in target:
			var push_direction = linear_velocity.normalized()
			target.velocity += push_direction * knockback_force
			
		# 3. ลบกระสุนทิ้งเมื่อยิงโดนศัตรู
		queue_free()
		
	# หากชนกำแพง/สิ่งกีดขวาง (ที่ไม่ใช่ผู้เล่น) ให้ลบกระสุนทิ้ง
	elif not target.is_in_group("Player"):
		queue_free()
