varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_sampler;
uniform lowp vec4 params; //x,y resolution, z time
uniform lowp vec4 tint;

#define PI 3.14159

float vDrop(vec2 uv,float t)
{
    uv.x = uv.x*128.0;						// H-Count
    float dx = fract(uv.x);
    uv.x = floor(uv.x);
    uv.y *= 0.05;							// stretch
    float o=sin(uv.x*215.4);				// offset
    float s=cos(uv.x*33.1)*.3 +.7;			// speed
    float trail = mix(35.0,15.0,s);			// trail length
    float yv = fract(uv.y + t*s + o) * trail;
    yv = 1.0/yv;
    yv = smoothstep(0.0,1.0,yv*yv);
    yv = sin(yv*PI)*(s*5.0);
    float d2 = sin(dx*PI);
    return yv*(d2*d2);
}

void main()
{
     vec4 texColor = texture2D(texture_sampler, var_texcoord0);
    vec2 p = (var_texcoord0.xy*params.xy - 0.5 * params.xy) / params.y;
    float d = length(p)+0.1;
    p = vec2(atan(p.x, p.y) / PI, 2.5 / d);
   //if (iMouse.z>0.5)	p.y *= 0.5;
    float t =  params.z*0.4;
    vec3 col;
    //col += vec3(1,1,1) * vDrop(p,t);	// white
//    col += vec3(1,1,1) * vDrop(p,t+0.33);	// white
    col += vec3(0.45,1.15,0.425) * vDrop(p,t+0.66);	// green
    float a = texColor.r + col.r+col.b+col.g;
   	gl_FragColor = vec4(col*(d*d), (1-a)*tint.w);
   //	gl_FragColor = vec4(tint.w,tint.w,tint.w, (1-a)*tint.w);
}
