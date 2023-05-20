varying mediump vec2 var_texcoord0;
varying highp vec3 var_position;


uniform lowp vec4 tint;
uniform highp vec4 fog;

uniform lowp sampler2D texture0;

void main()
{
    // Pre-multiply alpha since all Defold materials do that
    vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
    vec4 overlay_color = texture2D(texture0, var_texcoord0.xy) * tint_pm;


    // Fog
    float distance = abs(var_position.z);
    float fog_min = fog.x;
    float fog_max = fog.y;
    float fog_intensity = fog.w;
    float fog_factor = (1.0 - clamp((fog_max - distance) / (fog_max - fog_min), 0.0, 1.0)) * fog_intensity;


    overlay_color.rgb *= 1.0-fog_factor;
    // Color + Fog
    gl_FragColor = overlay_color;
}
