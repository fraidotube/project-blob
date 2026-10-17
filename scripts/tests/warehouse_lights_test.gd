extends SceneTree

const FIXTURE := "res://.godot/warehouse_lights_fixture.tscn"
const SWITCHES := ["Interruttore Luce Corridoio Magazzino", "Interruttore Luce Lampadario Magazzino", "Interruttore Luce Antibagno", "Interruttore Luce Bagno DX", "Interruttore Luce Bagno SX", "Interruttore Luce Ingresso Magazzino"]
const LIGHT_ROOTS := ["Luci Corridoio Magazzino", "Luci Lampadario Magazzino", "Luce AntiBagno", "Luce Bagno DX", "Luce Bagno SX", "Luce Ingresso Magazzino"]
var failures := 0
var resources: Dictionary = {}
var needed: Dictionary = {}

func _initialize() -> void:
	call_deferred("run")

func check(ok:bool,message:String) -> void:
	if not ok:
		failures+=1
		push_error(message)

func attribute(header:String,key:String) -> String:
	var pattern:=RegEx.create_from_string(' '+key+'="([^"]+)"')
	var found:=pattern.search(header)
	return found.get_string(1) if found else ""

func require_block(kind:String,id:String) -> void:
	var key:=kind+":"+id
	if needed.has(key):return
	assert(resources.has(key),"Missing real scene dependency: "+key)
	needed[key]=true
	var block:String=resources[key]
	var pattern:=RegEx.create_from_string('(ExtResource|SubResource)\\("([^"]+)"\\)')
	for match in pattern.search_all(block):require_block(match.get_string(1),match.get_string(2))

func build_fixture() -> void:
	# Extract only the real new nodes and their transitive resources. This
	# avoids loading the multi-GB building merely to test five switches.
	var source:=FileAccess.get_file_as_string("res://scenes/maps/map_test.tscn")
	var heading:=RegEx.create_from_string('(?m)^\\[(ext_resource|sub_resource|node|editable) [^\\r\\n]+\\]')
	var matches:=heading.search_all(source)
	var nodes:Array[String]=[]
	for i in matches.size():
		var match:RegExMatch=matches[i]
		var stop:=matches[i+1].get_start() if i+1<matches.size() else source.length()
		var block:=source.substr(match.get_start(),stop-match.get_start())
		var header:=match.get_string()
		var kind:=match.get_string(1)
		if kind=="ext_resource":resources["ExtResource:"+attribute(header,"id")]=block
		elif kind=="sub_resource":resources["SubResource:"+attribute(header,"id")]=block
		elif kind=="node":
			var name:=attribute(header,"name")
			var parent:=attribute(header,"parent")
			var in_light_branch:=parent in LIGHT_ROOTS
			for light_root:String in LIGHT_ROOTS:
				in_light_branch=in_light_branch or parent.begins_with(light_root+"/")
			if name=="ConnesiPower" or name in SWITCHES or name in LIGHT_ROOTS or in_light_branch:
				# This fixture omits the building models; their real materials
				# are exercised by warehouse_emission_map_test instead.
				block=RegEx.create_from_string('(?m)^emissive_visual_roots = [^\\r\\n]+\\r?\\n').sub(block,"",true)
				nodes.append(block)
	var references:=RegEx.create_from_string('(ExtResource|SubResource)\\("([^"]+)"\\)')
	for block in nodes:
		for match in references.search_all(block):require_block(match.get_string(1),match.get_string(2))
	var text:="[gd_scene format=4]\n\n"
	for key in resources:
		if needed.has(key):text+=String(resources[key])+"\n"
	text+='[node name="WarehouseLightsFixture" type="Node3D"]\n\n'
	for block in nodes:text+=block+"\n"
	var file:=FileAccess.open(FIXTURE,FileAccess.WRITE)
	file.store_string(text)
	file.close()

func lights(node:Node) -> Array[Light3D]:
	var result:Array[Light3D]=[]
	if node is Light3D:result.append(node)
	for child in node.get_children():result.append_array(lights(child))
	return result

func test_e_input(world:Node3D,switch:MeshInstance3D) -> void:
	var player:=Node3D.new()
	world.add_child(player)
	var head:=Node3D.new()
	head.name="Head"
	player.add_child(head)
	var camera:=Camera3D.new()
	camera.name="Camera3D"
	head.add_child(camera)
	var ray:=RayCast3D.new()
	ray.name="InteractRay"
	ray.collision_mask=2
	ray.target_position=Vector3(0,0,-2.5)
	camera.add_child(ray)
	var system:Node=load("res://scripts/systems/interaction_system.gd").new()
	system.set_process(false)
	var hud:=Control.new()
	hud.name="InteractionHUD"
	system.add_child(hud)
	var prompt:=Control.new()
	prompt.name="Prompt"
	hud.add_child(prompt)
	for name in ["Name","Action"]:
		var label:=Label.new()
		label.name=name
		prompt.add_child(label)
	player.add_child(system)
	system.set_process(true)
	var center:=switch.global_transform*switch.get_aabb().get_center()
	camera.global_position=center+switch.global_basis.z.normalized()*.4
	camera.look_at(center)
	await physics_frame
	await process_frame
	system._update_focus()
	check(system.focused_interactable==switch,"Real player ray did not focus switch")
	Input.action_press("interact")
	await process_frame
	await process_frame
	Input.action_release("interact")
	check(switch.lights_on,"E did not turn lights on")
	await process_frame
	Input.action_press("interact")
	await process_frame
	await process_frame
	Input.action_release("interact")
	check(not switch.lights_on,"Second E did not turn lights off")
	player.queue_free()

func run() -> void:
	root.get_node("AudioManager").fade_out_menu_music(.01)
	build_fixture()
	var packed:PackedScene=load(FIXTURE)
	check(packed!=null,"Real scene fixture did not parse")
	if packed==null:quit(1);return
	var world:=packed.instantiate()
	root.add_child(world)
	current_scene=world
	await process_frame
	var save:=root.get_node("SaveManager")
	var power:Node=world.get_node("ConnesiPower")
	var interaction:Node=load("res://scripts/systems/interaction_system.gd").new()
	var poses:Dictionary={}
	var energies:Dictionary={}
	for i in SWITCHES.size():
		var switch:MeshInstance3D=world.get_node(SWITCHES[i])
		poses[switch.name]=switch.transform
		check(switch.power_system==power and switch.lights_root==world.get_node(LIGHT_ROOTS[i]),"Wrong circuit binding")
		check(save.participants.get(switch.persistent_id)==switch,"Persistent ID missing")
		check(switch.get_node("InteractionBody").collision_layer==2,"Switch not on interaction layer")
		check(interaction._find_interactable(switch.get_node("InteractionBody"))==switch,"HUD cannot resolve switch collider")
		switch.interact(null)
		check(not switch.lights_on,"Switch works without company power")
		for lamp in lights(switch.lights_root):
			check(not lamp.visible,"New lights not initially off")
			energies[lamp.get_path()]=lamp.light_energy
	power.turn_on()
	await test_e_input(world,world.get_node(SWITCHES[0]))
	for i in SWITCHES.size():
		var switch:MeshInstance3D=world.get_node(SWITCHES[i])
		switch.interact(null)
		check(switch.lights_on and switch.switch_audio.playing,"Switch or sound failed")
		for j in SWITCHES.size():
			for lamp in lights(world.get_node(LIGHT_ROOTS[j])):
				check(lamp.visible==(j<=i),"Independent circuit changed")
		check(switch.get_interaction_action()=="SPEGNI","Wrong interaction prompt")
		switch.set_interaction_focus(true)
		check(switch.material_overlay!=null,"Original mesh not outlined")
		switch.set_interaction_focus(false)
		await physics_frame
		await physics_frame
		var center:Vector3=switch.global_transform*switch.get_aabb().get_center()
		var direction:Vector3=switch.global_basis.z.normalized()
		var query:=PhysicsRayQueryParameters3D.create(center+direction*.4,center-direction*.04,2)
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(query)
		check(not hit.is_empty() and interaction._find_interactable(hit.get("collider"))==switch,"Interaction ray misses "+String(switch.name))
		print("WAREHOUSE_SWITCH ",switch.name," bounds=",switch.get_aabb()," hit=",not hit.is_empty())
	# Capture/recreate actual scene nodes without reading/writing any save slot.
	world.get_node(SWITCHES[1]).interact(null)
	save.capture_world()
	world.queue_free()
	await process_frame
	await process_frame
	world=packed.instantiate()
	world.get_node("ConnesiPower").power_on=true
	root.add_child(world)
	current_scene=world
	await process_frame
	await process_frame
	power=world.get_node("ConnesiPower")
	for i in SWITCHES.size():
		var switch:MeshInstance3D=world.get_node(SWITCHES[i])
		check(switch.lights_on==(i!=1),"Circuit state not restored")
		check(not switch.switch_audio.playing,"Restore played switch sound")
		check(switch.transform==poses[switch.name],"Switch transform changed")
		for lamp in lights(switch.lights_root):check(lamp.light_energy==energies[lamp.get_path()],"Light energy changed")
	power.turn_off()
	for name in SWITCHES:
		var switch:Node=world.get_node(name)
		check(not switch.lights_on,"Power loss did not reset switch")
		for lamp in lights(switch.lights_root):check(not lamp.visible,"Blackout left light on")
	power.turn_on()
	for name in SWITCHES:check(not world.get_node(name).lights_on,"Power return unexpectedly reactivated lights")
	world.queue_free()
	interaction.free()
	await process_frame
	await process_frame
	for id in save.participants:check(not String(id).begins_with("main.lights."),"Switch persistence not cleaned up")
	await create_timer(.2).timeout
	print("WAREHOUSE_LIGHTS_TEST failures=",failures," switches=",SWITCHES.size()," lights=",energies.size()," source=real_map_fixture")
	quit(failures)
