varying highp vec4 var_position;
varying mediump vec3 var_normal;
varying mediump vec2 var_texcoord0;
varying highp vec4 var_color0;
varying mediump vec4 var_light;


uniform lowp vec4 tint;


void main()
{
    // Pre-multiply alpha since all runtime textures already are
    vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
    vec4 color = vec4(1)*tint_pm;

    gl_FragColor = vec4(var_color0.rgb, color.a);

}

