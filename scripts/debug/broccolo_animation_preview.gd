extends Node3D

const CHARACTER := preload("res://scenes/enemies/broccolo.tscn")
const MUSIC_PATH := "res://assets/audio/ProjecBloc - Broccolo.mp3"
const INTRO_PATH := "res://assets/models/enemies/broccolo/intro_broccolo.mp3"
const PRESENTATION := preload("res://scripts/debug/broccolo_presentation.gd")
const DANCES: Array[StringName] = [&"mie/dancing_test",&"mie/dancing",&"mie/dancing2",&"mie/dancing3",&"mie/dancing_salsa"]
@export var voice_stream: AudioStream
## Uso nella mappa: nessun ambiente, camera, interfaccia o comandi dello studio.
@export var map_presentation := false
## Applica gli spostamenti originali della telefonata anche nella presentazione mappa.
@export var phone_root_motion := true
## Scala dei soli spostamenti orizzontali, non della mesh o della postura.
@export_range(0.1, 2.0, 0.05) var world_motion_scale := 1.0
## Solo in mappa: ampiezza delle deviazioni laterali, per adattare il passo a corridoi stretti.
@export_range(0.0, 1.0, 0.05) var lateral_motion_scale := 1.0
## Scala proporzionalmente la traiettoria completa delle danze, senza cambiare il timing.
var dance_motion_scale := 0.5
@export var automatic_dance := false
@export_enum("Manuale", "Telefonata", "Discorso e danza") var automatic_presentation := 0
@export_range(0.0, 5.0, 0.1) var phone_answer_seconds := 3.5
@export_range(0.0, 60.0, 0.1) var phone_throw_seconds := 23.0
@export_range(1, 10, 1) var phone_walk_cycles := 3
@export_range(0.0, 60.0, 0.1) var discourse_dance_seconds := 21.0
@export_range(0.1, 1.5, 0.05) var presentation_blend_seconds := 0.55
var presentation: Node
var actor: Node3D
var animation: AnimationPlayer
var skeleton: Skeleton3D
var component: Node
var phone: Node
var head: MeshInstance3D
var original_head: MeshInstance3D
var music: AudioStreamPlayer
var voice: AudioStreamPlayer
var camera: Camera3D
var selector: OptionButton
var status: Label
var timeline: HSlider
var opening_slider: HSlider
var clip_names: Array[StringName] = []
var curves: Dictionary = {}
var rig_basis := Basis.IDENTITY
var clip_prefix := Vector3.ZERO
var dance_prefix := Vector3.ZERO
var dance_index := 0
var dance_start := 0.0
var sequence := false
var preview_paused := false
var travel := true
var closeup := false
var orbit := 0.0
var zoom := 1.0
var standing_height := 1.8
var shrink_tween: Tween
var ready_for_preview := false

func _ready() -> void:
	process_priority=20
	_lighting()
	actor=CHARACTER.instantiate()
	add_child(actor)
	skeleton=actor.get_node("Broccolo/Armature/GeneralSkeleton")
	animation=actor.get_node("Broccolo/AnimationPlayer")
	component=actor.get_node("MouthPresentation")
	head=actor.get_node("Broccolo/Armature/GeneralSkeleton/mixamorig1_Head/Testa")
	original_head=MeshInstance3D.new()
	original_head.mesh=head.mesh
	original_head.transform=head.transform
	original_head.visible=false
	head.get_parent().add_child(original_head)
	rig_basis=global_basis.inverse()*skeleton.global_basis
	var source:=animation.get_animation_library(&"mie")
	var private_library:=AnimationLibrary.new()
	for name in source.get_animation_list():
		var curve:=source.get_animation(name).duplicate(true) as Animation
		curves[StringName("mie/"+String(name))]=curve
		var local:=curve.duplicate(true) as Animation
		local.loop_mode=Animation.LOOP_NONE
		for track in local.get_track_count():
			var path:=local.track_get_path(track)
			if local.track_get_type(track)!=Animation.TYPE_POSITION_3D or path.get_subname_count()==0 or path.get_subname(0)!=&"mixamorig1_Hips":continue
			var track_start: Vector3 = local.position_track_interpolate(track, 0.0)
			for key in local.track_get_key_count(track):
				var value:Vector3=local.track_get_key_value(track,key)
				value.x=track_start.x
				value.z=track_start.z
				local.track_set_key_value(track,key,value)
		private_library.add_animation(name,local)
		clip_names.append(StringName("mie/"+String(name)))
	animation.remove_animation_library(&"mie")
	animation.add_animation_library(&"mie",private_library)
	music=AudioStreamPlayer.new()
	music.bus=&"Music"
	var stream:=AudioStreamMP3.new()
	stream.data=FileAccess.get_file_as_bytes(MUSIC_PATH)
	music.stream=stream
	add_child(music)
	music.finished.connect(_finish_dance)
	voice=AudioStreamPlayer.new()
	voice.bus=&"SFX"
	if voice_stream==null:
		var intro:=AudioStreamMP3.new()
		intro.data=FileAccess.get_file_as_bytes(INTRO_PATH)
		voice_stream=intro
	voice.stream=voice_stream
	add_child(voice)
	presentation=PRESENTATION.new()
	presentation.studio=self
	add_child(presentation)
	phone=actor.get_node_or_null("PhonePresentation")
	if phone!=null:phone.bind_sequence(presentation)
	if not map_presentation:
		camera=Camera3D.new()
		camera.near=.01
		camera.fov=35
		add_child(camera)
		camera.make_current()
	await get_tree().process_frame
	play_clip(&"mie/idle")
	animation.advance(0)
	await get_tree().process_frame
	standing_height=_measure_height()
	_build_ui()
	if not map_presentation:
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		AudioManager.fade_out_menu_music(.1)
	ready_for_preview=true
	print("BROCCOLO_PREVIEW_READY clips=",clip_names.size()," height=",standing_height," music_seconds=",music.stream.get_length())
	if automatic_dance:start_dance()
	elif automatic_presentation==1:start_introduction()
	elif automatic_presentation==2:start_discourse()

func _lighting() -> void:
	if map_presentation:return
	var world:=WorldEnvironment.new()
	world.environment=Environment.new()
	world.environment.background_mode=Environment.BG_COLOR
	world.environment.background_color=Color("25272e")
	world.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color=Color("dde3f2")
	world.environment.ambient_light_energy=.5
	add_child(world)
	var floor_mesh:=MeshInstance3D.new()
	var plane:=PlaneMesh.new()
	plane.size=Vector2(1000,1000)
	floor_mesh.mesh=plane
	var material:=ShaderMaterial.new()
	material.shader=preload("res://assets/shaders/broccolo_studio_floor.gdshader")
	floor_mesh.material_override=material
	add_child(floor_mesh)
	var floor_body:=StaticBody3D.new()
	var floor_collision:=CollisionShape3D.new()
	var floor_shape:=BoxShape3D.new()
	floor_shape.size=Vector3(1000,.2,1000)
	floor_collision.shape=floor_shape
	floor_body.position.y=-.1
	floor_body.add_child(floor_collision)
	add_child(floor_body)
	for position in [Vector3(-3,5,4),Vector3(4,3,-2)]:
		var light:=DirectionalLight3D.new()
		light.rotation_degrees=Vector3(-35,-35,0) if position.z>0 else Vector3(-25,135,0)
		light.light_energy=.9 if position.z>0 else .45
		add_child(light)

func _build_ui() -> void:
	if map_presentation:
		# The shared sequencer needs these controls as optional state holders only.
		selector=OptionButton.new()
		for name in clip_names:selector.add_item(String(name))
		selector.hide()
		add_child(selector)
		timeline=HSlider.new()
		timeline.hide()
		add_child(timeline)
		return
	var canvas:=CanvasLayer.new()
	add_child(canvas)
	var panel:=PanelContainer.new()
	panel.position=Vector2(16,16)
	panel.custom_minimum_size=Vector2(300,0)
	canvas.add_child(panel)
	var box:=VBoxContainer.new()
	panel.add_child(box)
	var title:=Label.new()
	title.text="BROCCOLO — studio animazioni"
	box.add_child(title)
	selector=OptionButton.new()
	for name in clip_names:selector.add_item(String(name).trim_prefix("mie/")+"  (%.2f s)"%animation.get_animation(name).length)
	selector.select(clip_names.find(StringName(animation.assigned_animation)))
	box.add_child(selector)
	selector.item_selected.connect(func(index:int):play_clip(clip_names[index]))
	_button(box,"Riproduci clip / ricomincia",func():play_clip(clip_names[selector.selected]))
	_button(box,"Pausa / riprendi  [Spazio]",toggle_pause)
	_button(box,"1 · Intro: telefono, lancio, camminata",start_introduction)
	_button(box,"2 · Discorso, danza 3/2/1, miniatura",start_discourse)
	_button(box,"Danza + musica → miniatura",start_dance)
	_button(box,"Ferma danza e torna idle",stop_dance)
	var movement:=CheckButton.new()
	movement.text="Spostamento reale del personaggio"
	movement.button_pressed=true
	movement.toggled.connect(func(value:bool):travel=value)
	box.add_child(movement)
	timeline=HSlider.new()
	timeline.min_value=0
	timeline.step=.01
	timeline.custom_minimum_size=Vector2(280,20)
	timeline.value_changed.connect(_seek_clip)
	box.add_child(timeline)
	_button(box,"Volto / figura intera  [F]",func():closeup=not closeup)
	_button(box,"Frontale / tre quarti  [1 / 2]",func():orbit=.55 if orbit==0 else 0.0)
	_button(box,"Confronto testa originale  [O]",_compare_head)
	var label:=Label.new()
	label.text="Bocca manuale (0 = chiusa)"
	box.add_child(label)
	opening_slider=HSlider.new()
	opening_slider.min_value=0
	opening_slider.max_value=1
	opening_slider.step=.01
	opening_slider.value_changed.connect(func(value:float):presentation.stop();voice.stop();component.bind_voice(null);component.set_expression(value))
	box.add_child(opening_slider)
	_button(box,"Forma O",func():component.bind_voice(null);component.set_expression(opening_slider.value,1,0))
	_button(box,"Sorriso",func():component.bind_voice(null);component.set_expression(opening_slider.value,0,1))
	_button(box,"Ascolta intro_broccolo",play_voice)
	_button(box,"Rimpicciolisci a 20 cm",shrink_preview)
	_button(box,"Ripristina dimensione e posizione",reset_preview)
	status=Label.new()
	status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	status.custom_minimum_size=Vector2(290,64)
	box.add_child(status)
	var hint:=Label.new()
	hint.text="Destro: ruota vista · Rotella: zoom"
	box.add_child(hint)

func _button(box:VBoxContainer,text:String,callback:Callable) -> void:
	var button:=Button.new()
	button.text=text
	button.pressed.connect(callback)
	box.add_child(button)

func play_clip(name:StringName,keep_position:bool=false) -> void:
	if presentation!=null:presentation.stop()
	if shrink_tween!=null:shrink_tween.kill()
	if voice!=null:
		voice.stop()
		component.bind_voice(null)
	sequence=false
	music.stop()
	preview_paused=false
	clip_prefix=actor.position if keep_position else Vector3.ZERO
	animation.play(name,.2)
	animation.advance(0)
	animation.seek(0,true)
	if selector!=null:selector.select(clip_names.find(name))
	if timeline!=null:timeline.max_value=animation.get_animation(name).length
	_update_motion()

func _root_offset(name:StringName,time:float) -> Vector3:
	var curve:Animation=curves[name]
	for track in curve.get_track_count():
		if curve.track_get_type(track)!=Animation.TYPE_POSITION_3D:continue
		var path:=curve.track_get_path(track)
		if path.get_subname_count()==0 or path.get_subname(0)!=&"mixamorig1_Hips":continue
		var start:=curve.position_track_interpolate(track,0)
		var value:=curve.position_track_interpolate(track,clampf(time,0,curve.length))
		var lateral := lateral_motion_scale if map_presentation else 1.0
		return rig_basis*Vector3((value.x-start.x)*lateral,0,value.z-start.z)*world_motion_scale
	return Vector3.ZERO

func _update_motion() -> void:
	var name:=StringName(animation.assigned_animation)
	if not curves.has(name):return
	var ratio:=actor.scale.x
	var moving:bool=travel and not (presentation!=null and presentation.active() and presentation.stationary())
	if map_presentation and phone_root_motion and presentation.stage in ["answer","phone"]:moving=travel
	if map_presentation and presentation!=null and presentation.stage=="dance":
		# Le clip privata conserva la posa sul posto; applica qui il moto originale
		# delle anche, ruotato col fronte attuale di Broccolo, durante tutta la coreografia.
		actor.position=clip_prefix+actor.basis*(_root_offset(name,animation.current_animation_position)*ratio*dance_motion_scale)
	else:
		actor.position=clip_prefix+(_root_offset(name,animation.current_animation_position)*ratio if moving else Vector3.ZERO)

func start_dance() -> void:
	reset_preview()
	voice.stop()
	component.bind_voice(null)
	component.set_expression(0)
	dance_index=0
	dance_start=0
	dance_prefix=Vector3.ZERO
	clip_prefix=Vector3.ZERO
	animation.play(DANCES[0],.2)
	selector.select(clip_names.find(DANCES[0]))
	animation.advance(0)
	sequence=true
	music.stream_paused=false
	music.play()

func start_introduction() -> void:
	presentation.start_phone()

func start_discourse(preserve_actor_transform := false) -> void:
	var saved_actor_transform := actor.global_transform if preserve_actor_transform else Transform3D.IDENTITY
	presentation.start_discourse()
	if preserve_actor_transform:
		actor.global_transform = saved_actor_transform
		clip_prefix = actor.position
		_update_motion()

func _finish_dance() -> void:
	if not sequence:return
	sequence=false
	play_clip(&"mie/idle",true)
	shrink_preview()

func stop_dance() -> void:
	sequence=false
	music.stop()
	play_clip(&"mie/idle")

func toggle_pause() -> void:
	preview_paused=not preview_paused
	music.stream_paused=preview_paused
	voice.stream_paused=preview_paused
	if presentation.stage=="throw":voice.stream_paused=true
	if shrink_tween!=null and shrink_tween.is_valid():
		if preview_paused:shrink_tween.pause()
		else:shrink_tween.play()
	if preview_paused:animation.pause()
	else:animation.play(animation.assigned_animation)

func _seek_clip(value:float) -> void:
	if sequence or presentation.active():return
	animation.seek(value,true)
	_update_motion()

func play_voice() -> void:
	presentation.stop()
	if voice_stream==null:
		status.text="Assegna voice_stream sulla scena di prova quando il discorso è pronto."
		return
	voice.stream=voice_stream
	voice.stream_paused=false
	component.bind_voice(voice)
	voice.play()

func _compare_head() -> void:
	original_head.visible=not original_head.visible
	head.visible=not original_head.visible

func _measure_height() -> float:
	var low:=INF
	var high:=-INF
	for mesh in actor.find_children("*","MeshInstance3D",true,false):
		if not mesh.visible:continue
		var bounds: AABB=mesh.get_aabb()
		for i in range(8):
			var point:Vector3=mesh.global_transform*bounds.get_endpoint(i)
			low=minf(low,point.y)
			high=maxf(high,point.y)
	return maxf(.1,high-low)

func shrink_preview() -> void:
	if shrink_tween!=null:shrink_tween.kill()
	shrink_tween=create_tween()
	shrink_tween.tween_property(actor,"scale",Vector3.ONE*(.2/standing_height),2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func reset_preview() -> void:
	if presentation!=null:presentation.stop()
	if phone!=null and phone.has_method("reset_phone"):phone.reset_phone()
	sequence=false
	if music!=null:music.stop()
	if music!=null:music.volume_db=0
	if voice!=null:
		voice.stop()
		voice.stream_paused=false
		component.bind_voice(null)
	if shrink_tween!=null:shrink_tween.kill()
	actor.scale=Vector3.ONE
	actor.position=Vector3.ZERO
	clip_prefix=Vector3.ZERO
	preview_paused=false
	if animation!=null:animation.play(&"mie/idle")

func _process(_delta:float) -> void:
	if not ready_for_preview:return
	if sequence and not preview_paused:
		var time:=music.get_playback_position()
		var clip:Animation=animation.get_animation(DANCES[dance_index])
		while time-dance_start>=clip.length:
			dance_prefix+=_root_offset(DANCES[dance_index],clip.length)
			dance_start+=clip.length
			dance_index=(dance_index+1)%DANCES.size()
			clip=animation.get_animation(DANCES[dance_index])
			animation.play(DANCES[dance_index],.2)
			selector.select(clip_names.find(DANCES[dance_index]))
		clip_prefix=dance_prefix
		animation.seek(time-dance_start,true)
	_update_motion()
	if map_presentation:return
	timeline.set_value_no_signal(animation.current_animation_position)
	var target:=actor.position+Vector3.UP*(standing_height*.50*actor.scale.y)
	if closeup:target=head.global_transform*head.mesh.get_aabb().get_center()
	var viewport_size:=get_viewport().get_visible_rect().size
	var aspect:=viewport_size.x/maxf(viewport_size.y,1)
	var full_distance:=maxf(4.1,2.1/(2*tan(deg_to_rad(camera.fov)*.5)*aspect)*1.1)
	var distance:float=(.65 if closeup else full_distance)*zoom*maxf(actor.scale.y,.2)
	camera.position=target+Vector3(sin(orbit)*distance,.1*distance,cos(orbit)*distance)
	camera.look_at(target)
	status.text="%s · %.2f / %.2f s\n%s · altezza nominale %.2f m"%[String(animation.assigned_animation),animation.current_animation_position,animation.get_animation(animation.assigned_animation).length,"Danza con musica" if sequence else "Clip singola",standing_height*actor.scale.y]
	if presentation.active():status.text=presentation.description()+"\n%s · voce %.2f s · %.2f m"%[String(animation.assigned_animation).trim_prefix("mie/"),voice.get_playback_position(),standing_height*actor.scale.y]

func _unhandled_input(event:InputEvent) -> void:
	if map_presentation:return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:toggle_pause()
			KEY_F:closeup=not closeup
			KEY_1:orbit=0
			KEY_2:orbit=.55
			KEY_O:_compare_head()
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):orbit-=event.relative.x*.008
	if event is InputEventMouseButton and event.pressed:
		if event.button_index==MOUSE_BUTTON_WHEEL_UP:zoom=maxf(.3,zoom*.9)
		if event.button_index==MOUSE_BUTTON_WHEEL_DOWN:zoom=minf(3,zoom*1.1)
