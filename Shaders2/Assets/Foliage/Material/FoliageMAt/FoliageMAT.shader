Shader "Unlit/FoliageMAT"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GrassTex("_GrassTex", 2D) = "white" {}

        _ObjectRadius("_ObjectRadius" , Range(0,5)) = 0

        _Color("Grass Color" , Color) =(1,1,1,1)

        _Cutoff("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "Queue"= "AlphaTest" "RenderType"="TransparentCutout" }
        LOD 100
        Cull Off // turn off backface culling

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"


            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _GrassTex;
            fixed4 _Color;

            half _Cutoff;

            uniform float4 _ObjectPosition;
            half _ObjectRadius;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;

                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                half d = distance(_ObjectPosition, worldPos);
                half sum = saturate((d - _ObjectRadius));

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
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
