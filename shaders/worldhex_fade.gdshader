shader_type spatial;
render_mode blend_mix,
depth_draw_opaque,
depth_test_default,
cull_back,
diffuse_lambert,
specular_schlick_ggx,
unshaded,
shadows_disabled;

uniform vec4 custom_color : source_color = vec4(1.000000, 1.000000, 1.000000, 1.000000);

void fragment() {
	vec2 uv = UV;
	
	ALBEDO = vec3(custom_color.xyz);
	ALPHA = length(vec2(uv.x*2.0f-1.0f,uv.y*2.0f-1.0f));
}
