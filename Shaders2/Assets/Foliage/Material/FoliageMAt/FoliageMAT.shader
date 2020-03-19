// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/FoliageMAT"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GrassTex("_GrassTex", 2D) = "white" {}

        _ObjectStrentgh("_ObjectStrentgh" , Float) = 0
        _GrassDownLevel("_GrassDownLevel" , Float) = 0

        _Color("Grass Color" , Color) =(1,1,1,1)

        _Cutoff("Alpha cutoff", Range(0,1)) = 0.5

        _NoiseTex("_NoiseTex", 2D) = "white" {}
        _WindSpeed("_WindSpeed", Float) = 0.5
        _WindMouv("_WindMouv", Float) = 0.5
        _WindOffset("_WindOffset", Float) = 0.5

    }
    SubShader
    {
        Tags {  "RenderType"="Opaque" }
        LOD 100
        Cull Off // turn off backface culling

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"


            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            half _WindSpeed;
            half _WindMouv;
            half _WindOffset;

            sampler2D _GrassTex;
            fixed4 _Color;

            half _Cutoff;

            uniform float4 _ObjectPosition;
            uniform half _ObjectRadius;
            half _ObjectStrentgh;
            half _GrassDownLevel;

            /*
            // 2D Random
            float random(in float2 st) 
            {
                return frac(sin(dot(st.xy,float2(12.9898, 78.233)))* 43758.5453123);
            }

            // 2D Noise based on Morgan McGuire @morgan3d
            float noise(in float2 st) 
            {
                float2 i = floor(st);
                float2 f = frac(st);

                // Four corners in 2D of a tile
                float a = random(i);
                float b = random(i + float2(1.0, 0.0));
                float c = random(i + float2(0.0, 1.0));
                float d = random(i + float2(1.0, 1.0));

                // Smooth Interpolation

                // Cubic Hermine Curve.  Same as SmoothStep()
                float2 u = f * f * (3.0 - 2.0 * f);
                // u = smoothstep(0.,1.,f);

                // Mix 4 coorners percentages
                return lerp(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
            }
            */

            float Sign(float number) 
            {
                return number < 0 ? -1 : (number > 0 ? 1 : 0);
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 noise : TEXCOORD1;               
                float4 worldPos : TEXCOORD2;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 noise : TEXCOORD1;
                float4 worldPos : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;

                //Link to the ball
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                half d = distance(_ObjectPosition, o.worldPos);
                //half dx = clamp(distance(o.worldPos.x, _ObjectPosition.x) - _ObjectRadius, -1, 1);
                //half dz = clamp(distance(o.worldPos.z, _ObjectPosition.z) - _ObjectRadius, -_ObjectRadius, 1);

                float sum = clamp((d - _ObjectRadius), -_ObjectRadius, 1);
                float sumX = clamp((d - _ObjectRadius), -_ObjectRadius, 1) * Sign(sign(o.worldPos.x - _ObjectPosition.x));

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //Offset && Tilling
                o.noise = v.noise.xy * _NoiseTex_ST.xy + (_NoiseTex_ST.zw + (_Time.x * _WindSpeed) + o.worldPos.x ) + (_Time.x * _WindMouv);
                o.vertex.x += step(0, o.uv.y - _WindOffset) * tex2Dlod(_NoiseTex, float4(o.noise.xy, 0, 0)).r;

                o.vertex.x += step(0, o.uv.y) * -sumX;
                o.vertex.y += step(0, o.uv.y - _WindOffset) * -sum;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 grassTex = tex2D(_GrassTex, i.uv);

                clip(col.a - _Cutoff);
                col.rgb *= col.a;
                col *= grassTex * _Color;

                return col;
            }
            ENDCG
        }
    }
}
