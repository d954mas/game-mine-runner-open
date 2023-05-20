varying mediump vec2 var_texcoord0;
varying highp vec3 var_position;


uniform lowp vec4 tint;

uniform lowp sampler2D texture0;

void main()
{
    // Pre-multiply alpha since all Defold materials do that
    vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
    vec4 overlay_color = texture2D(texture0, var_texcoord0.xy) * tint_pm;
    // Color + Fog
    gl_FragColor = overlay_color;
}
