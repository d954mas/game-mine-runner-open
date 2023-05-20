varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_sampler;
uniform lowp vec4 tint;
uniform lowp vec4 vignette_params;

//RADIUS of our vignette, where 0.5 results in a circle fitting the screen
//const float RADIUS = 0.80; vignette_params.x

//softness of our vignette, between 0.0 and 1.0
//const float SOFTNESS = 0.45; vignette_params.y

void main()
{

    //sample our texture
    vec4 texColor = texture2D(texture_sampler, var_texcoord0);

    //determine center
    vec2 position = var_texcoord0 - vec2(0.5);

    //OPTIONAL: correct for aspect ratio
    //position.x *= resolution.x / resolution.y;

    //determine the vector length from center
    float len = length(position);

    //our vignette effect, using smoothstep
    float vignette = smoothstep(vignette_params.x, vignette_params.x-vignette_params.y, len);

    //apply our vignette
    texColor.rgb *= tint.rgb;
    texColor.a =  1.0-vignette;

    texColor.rgb *= texColor.a;

    gl_FragColor = texColor;
}
