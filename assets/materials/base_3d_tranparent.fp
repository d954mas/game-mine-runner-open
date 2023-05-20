varying highp vec3 var_world_position;
varying mediump vec3 var_world_normal;
varying highp vec3 var_position;
varying mediump vec3 var_normal;
varying highp vec2 var_texcoord0;

uniform lowp vec4 tint;
uniform highp vec4 fog;
uniform lowp vec4 fog_color;
uniform mediump vec4 light_directional;
uniform mediump vec4 light_ambient;

uniform lowp sampler2D texture0;

void main()
{
    // Pre-multiply alpha since all Defold materials do that
    vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);


    vec4 overlay_color = texture2D(texture0, var_texcoord0.xy) * tint_pm;
    if(overlay_color.a < 0.01){discard;}
    overlay_color = overlay_color * tint_pm;

    
    // Directional light
    float diff_intensity = light_directional.w;
    float diff_light = max(dot(var_world_normal, normalize(light_directional.xyz)), 0.0) * diff_intensity;
    float ambient_intensity = light_ambient.w;
    vec3 light = (ambient_intensity + diff_light) * light_ambient.rgb;
    vec3 final_color = (tint_pm.rgb * overlay_color.rgb) * light;

    // Fog
    float distance = abs(var_position.z);
    float fog_min = fog.x;
    float fog_max = fog.y;
    float fog_intensity = fog.w;
    float fog_factor = (1.0 - clamp((fog_max - distance) / (fog_max - fog_min), 0.0, 1.0)) * fog_intensity;

    // Color + Fog
    gl_FragColor = vec4(mix(final_color, fog_color.rgb, fog_factor),overlay_color.a*0.2);
}

