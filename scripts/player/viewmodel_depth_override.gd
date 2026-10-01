extends Node

# Project Blob V4.6.3 - SAFE viewmodel depth compression (flashlight fix).
# Keep the primary camera and real environment lighting.
# Preserve normal depth testing between the hands, pistol and flashlight.
# Only compress clip-space Z of local material copies so the viewmodel is in front of scenery.
# No imported assets or shared materials are modified.

const VIEWMODEL_PATH: NodePath = ^"Head/Camera3D/WeaponHolder/LowWorldViewModel"

# Opaque and masked materials. Custom ShaderMaterial stays untouched and is logged.
const VERTEX_CODE := """
void vertex() {
    vec4 view_position = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
    POSITION = PROJECTION_MATRIX * view_position;
    // Godot 4.3+ Forward+ uses reverse Z: 1.0 is near, 0.0 is far.
    // Keep real XY/perspective and distinct depth for each hand/weapon surface.
    float view_distance = clamp(-view_position.z / 12.0, 0.0, 1.0);
    POSITION.z = POSITION.w * (0.9995 - view_distance * 0.0015);
}
"""

const FRAGMENT_CODE := """
uniform sampler2D vm_albedo_texture : source_color, filter_linear_mipmap;
uniform bool vm_has_texture = false;
uniform vec4 vm_albedo_tint : source_color = vec4(1.0);
uniform float vm_roughness = 1.0;
uniform float vm_metallic = 0.0;
uniform bool vm_has_normal = false;
uniform sampler2D vm_normal_texture : hint_normal, filter_linear_mipmap;
uniform float vm_normal_scale = 1.0;

void fragment() {
    vec4 tex_color = vm_has_texture ? texture(vm_albedo_texture, UV) : vec4(1.0);
    ALBEDO = tex_color.rgb * vm_albedo_tint.rgb;
    ROUGHNESS = vm_roughness;
    METALLIC = vm_metallic;
    if (vm_has_normal) {
        NORMAL_MAP = texture(vm_normal_texture, UV).rgb;
        NORMAL_MAP_DEPTH = vm_normal_scale;
    }
}
"""

# Only alpha-marked imported surfaces use the cutout variant. Opaque hands and
# pistol keep their original fully opaque depth-writing shader unchanged.
const ALPHA_SCISSOR_FRAGMENT := """
uniform sampler2D vm_albedo_texture : source_color, filter_linear_mipmap;
uniform bool vm_has_texture = false;
uniform vec4 vm_albedo_tint : source_color = vec4(1.0);
uniform float vm_roughness = 1.0;
uniform float vm_metallic = 0.0;
uniform bool vm_has_normal = false;
uniform sampler2D vm_normal_texture : hint_normal, filter_linear_mipmap;
uniform float vm_normal_scale = 1.0;

void fragment() {
    vec4 tex_color = vm_has_texture ? texture(vm_albedo_texture, UV) : vec4(1.0);
    ALBEDO = tex_color.rgb * vm_albedo_tint.rgb;
    ALPHA = tex_color.a * vm_albedo_tint.a;
    ALPHA_SCISSOR_THRESHOLD = 0.5;
    ROUGHNESS = vm_roughness;
    METALLIC = vm_metallic;
    if (vm_has_normal) {
        NORMAL_MAP = texture(vm_normal_texture, UV).rgb;
        NORMAL_MAP_DEPTH = vm_normal_scale;
    }
}
"""

var _shaders: Dictionary = {}
var _changed: int = 0
var _skipped: int = 0

func _ready() -> void:
    var model: Node3D = get_parent().get_node_or_null(VIEWMODEL_PATH) as Node3D
    if model == null:
        push_error("ViewmodelDepthOverride: LowWorldViewModel not found")
        return
    _process_node(model)
    print("ViewmodelDepthOverride V4.6.3: %d materials updated, %d unsupported left unchanged" % [_changed, _skipped])

func _process_node(node: Node) -> void:
    if node is GeometryInstance3D:
        var geometry: GeometryInstance3D = node as GeometryInstance3D
        geometry.layers = 1
        geometry.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    if node is MeshInstance3D:
        _process_mesh(node as MeshInstance3D)
    for child: Node in node.get_children():
        _process_node(child)

func _process_mesh(mesh_node: MeshInstance3D) -> void:
    if mesh_node.material_override != null:
        var overridden: Material = _compressed_copy(mesh_node.material_override, mesh_node.get_path())
        if overridden != null:
            mesh_node.material_override = overridden
        return
    if mesh_node.mesh == null:
        return
    for index: int in range(mesh_node.mesh.get_surface_count()):
        var original: Material = mesh_node.get_active_material(index)
        if original == null:
            push_warning("ViewmodelDepthOverride: no active material for %s surface %d" % [str(mesh_node.get_path()), index])
            continue
        var replacement: Material = _compressed_copy(original, mesh_node.get_path())
        if replacement != null:
            mesh_node.set_surface_override_material(index, replacement)
    # Existing overlays (if present) are preserved, not depth modified.

func _compressed_copy(original: Material, mesh_path: NodePath) -> Material:
    if not original is BaseMaterial3D:
        _skipped += 1
        push_warning("ViewmodelDepthOverride: unsupported %s at %s (material: %s)" % [original.get_class(), str(mesh_path), original.resource_path])
        return null
    var base: BaseMaterial3D = original as BaseMaterial3D
    # The GLB flashlight may import alpha-blended or alpha-cutout materials.
    # Convert them to alpha scissor to retain proper internal depth ordering.
    # ShaderMaterial and truly translucent glass still need a dedicated solution.
    var use_scissor: bool = base.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED
    var key: int = int(base.cull_mode) * 2 + int(use_scissor)
    if not _shaders.has(key):
        var culling: String = "cull_back"
        if base.cull_mode == BaseMaterial3D.CULL_DISABLED:
            culling = "cull_disabled"
        elif base.cull_mode == BaseMaterial3D.CULL_FRONT:
            culling = "cull_front"
        var shader := Shader.new()
        shader.code = "shader_type spatial;\nrender_mode depth_draw_opaque, %s, diffuse_burley, specular_schlick_ggx;\n" % culling + VERTEX_CODE + (ALPHA_SCISSOR_FRAGMENT if use_scissor else FRAGMENT_CODE)
        _shaders[key] = shader
    var result := ShaderMaterial.new()
    result.shader = _shaders[key]
    result.set_shader_parameter(&"vm_albedo_tint", base.albedo_color)
    result.set_shader_parameter(&"vm_roughness", base.roughness)
    result.set_shader_parameter(&"vm_metallic", base.metallic)
    if base.albedo_texture != null:
        result.set_shader_parameter(&"vm_has_texture", true)
        result.set_shader_parameter(&"vm_albedo_texture", base.albedo_texture)
    if base.normal_enabled and base.normal_texture != null:
        result.set_shader_parameter(&"vm_has_normal", true)
        result.set_shader_parameter(&"vm_normal_texture", base.normal_texture)
        result.set_shader_parameter(&"vm_normal_scale", base.normal_scale)
    _changed += 1
    return result
