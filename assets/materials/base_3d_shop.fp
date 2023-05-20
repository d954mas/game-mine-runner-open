varying highp vec3 var_world_position;
varying mediump vec3 var_world_normal;
varying highp vec3 var_position;
varying mediump vec3 var_normal;
varying highp vec2 var_texcoord0;

uniform lowp vec4 tint;
uniform mediump vec4 light_ambient;

uniform lowp sampler2D texture0;

void main()
{
    // Pre-multiply alpha since all Defold materials do that
    vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);


    vec4 overlay_color = texture2D(texture0, var_texcoord0.xy) * tint_pm;
    

    
    // Directional light
    float diff_intensity = 0.5;
    float diff_light = max(dot(var_world_normal, normalize(vec3(0.0,1.0,1.0))), 0.0) * diff_intensity;
    float ambient_intensity = 1.0-diff_intensity;
    vec3 light = (ambient_intensity + diff_light) * light_ambient.rgb;
    vec3 final_color = (tint_pm.rgb * overlay_color.rgb) * light;



    // Color + Fog
    gl_FragColor = vec4(final_color.rgb, tint_pm.w);
}

