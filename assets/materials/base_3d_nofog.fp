varying highp vec3 var_world_position;
varying mediump vec3 var_world_normal;
varying highp vec3 var_position;
varying mediump vec3 var_normal;
varying highp vec2 var_texcoord0;

uniform mediump vec4 light_directional;
uniform mediump vec4 light_ambient;

uniform lowp sampler2D texture0;

void main()
{
    vec4 overlay_color = texture2D(texture0, var_texcoord0.xy);
    
    // Directional light
    float diff_intensity = light_directional.w;
    float diff_light = max(dot(var_world_normal, normalize(light_directional.xyz)), 0.0) * diff_intensity;
    float ambient_intensity = light_ambient.w;
    vec3 light = (ambient_intensity + diff_light) * light_ambient.rgb;
    vec3 final_color =  overlay_color.rgb * light;

    // Color + Fog
    gl_FragColor = vec4(final_color.rgb,overlay_color.a);
}

