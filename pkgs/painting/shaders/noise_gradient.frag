#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uOffset;
uniform vec2 uSize;
uniform float uTime;

uniform float uFrequency;
uniform float uAmplitude;
uniform float uSpeed;
uniform float uGrain;

uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uColor4;

out vec4 fragColor;

mat2 rotate(float a)
{
  float s = sin(a);
  float c = cos(a);
  return mat2(c, -s, s, c);
}

// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
vec2 hash( vec2 p )
{
  p = vec2( dot(p,vec2(2127.1,81.17)), dot(p,vec2(1269.5,283.37)) );
	return fract(sin(p)*43758.5453);
}

float noise( in vec2 p )
{
  vec2 i = floor( p );
  vec2 f = fract( p );
  vec2 u = f*f*(3.0-2.0*f);
  float n = mix( mix( dot( -1.0+2.0*hash( i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ),
                      dot( -1.0+2.0*hash( i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
                  mix( dot( -1.0+2.0*hash( i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ),
                      dot( -1.0+2.0*hash( i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
  return 0.5 + 0.5*n;
}

float grainNoise(vec2 p)
{
  // Two typical hashes...
  return fract(sin(dot(p * -1., vec2(12.9898, 78.233))) * 43758.5453);
}

void main()
{
  vec2 xy = FlutterFragCoord().xy;
  vec2 rect = uOffset + uSize;

  if(xy.x > uOffset.x && xy.y > uOffset.y && xy.x < rect.x && xy.y < rect.y) {
    vec2 uv = (xy - uOffset) / uSize;
    float ratio = uSize.x / uSize.y;

    vec2 tuv = uv;
    tuv -= .5;

    // rotate with Noise
    float degree = noise(vec2(uTime*.1, tuv.x*tuv.y));

    tuv.y *= 1./ratio;
    tuv *= rotate(radians((degree-.5)*720.+180.));
    tuv.y *= ratio;


    // Wave warp with sin
    float frequency = uFrequency;
    float amplitude = uAmplitude;
    float speed = uTime * uSpeed;

    tuv.x += sin(tuv.y*frequency+speed)/amplitude;
    tuv.y += sin(tuv.x*frequency*1.5+speed)/(amplitude*.5);



    // draw the image
    vec3 layer1 = mix(uColor1, uColor2, smoothstep(-.3, .2, (tuv*rotate(radians(-5.))).x));

    vec3 layer2 = mix(uColor3, uColor4, smoothstep(-.3, .2, (tuv*rotate(radians(-5.))).x));

    vec3 finalComp = mix(layer1, layer2, smoothstep(.5, -.3, tuv.y));

    vec3 grainedComp = vec3(finalComp + (finalComp * grainNoise(uv) * uGrain));

    vec3 col = grainedComp;

    fragColor = vec4(col,1.0);
  } else {
    fragColor = vec4(0.0, 0.0, 0.0, 1.0);
  }


}
