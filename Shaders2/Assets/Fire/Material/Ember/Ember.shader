Shader "Custom/Ember"
{
    Properties
    {
         //Base
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _MainHeight("_MainHeight", 2D) = "white" {}

        //Burn Effect
        _BurnColor("BurnColor", Color) = (1,1,1,1)
        _BurnSoftness("BurnSoftness", Range(0,5)) = 0
        _BurnRadius("BurnRadius", Range(0,5)) = 0

         //EmberBase
        _EmberColor("EmberColor", Color) = (1,1,1,1)
        _EmberTex("EmberTex (RGB)", 2D) = "white" {}

        //Emission
        _EmissionColor("EmissionColor", Color) = (1,1,1,1)
        _EmissionTex("EmissionTex (RGB)", 2D) = "white" {}
        _EmissionStrentgh("EmissionStrentgh", Range(0,4)) = 0

         //Circle
        //_Position ("Position", Vector) = (0,0,0,0)
        _Radius ("Radius" , Range(0,5)) = 0
        _Softness("Softness", Range(0,5)) = 0

        //Normal + Parallax
        _Normal("Normal", 2D) = "bump" {}
        _Height("Height", 2D) = "white" {}
        _Parallax("Parallax", Range(0,0.5)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _MainHeight;
        sampler2D _EmberTex;
        sampler2D _EmissionTex;
        sampler2D _Normal;
        sampler2D _Height;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_MainHeight;
            float2 uv_EmberTex;
            float2 uv_EmissionTex;
            float2 uv_Normal;
            float2 uv_Height;

            float3 worldPos;
            float3 viewDir;
        };

        fixed4 _Color;
        fixed4 _BurnColor;
        fixed4 _EmberColor;
        fixed4 _EmissionColor;

        uniform float4 _Position;
        half _Radius;
        half _Softness;
        half _BurnRadius;
        half _BurnSoftness;
        half _EmissionStrentgh;
        float _Parallax;


        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            half d = distance(_Position, IN.worldPos);
            half sum = saturate((d - _Radius) / -_Softness);
            half burnSum = saturate((d - _BurnRadius) / -_BurnSoftness);

            //Parallax Calcul
            float heightTex = tex2D(_Height, IN.uv_Height).r;
            float mainHeightTex = tex2D(_MainHeight, IN.uv_MainHeight).r;

            float lerpHeight = lerp(mainHeightTex, heightTex, sum);
            float2 parallaxOffset = ParallaxOffset(lerpHeight, _Parallax, IN.viewDir);


            fixed4 lerpColor = lerp(_Color, _BurnColor, burnSum);

            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex + parallaxOffset) * lerpColor;
            fixed4 ember = tex2D(_EmberTex, IN.uv_EmberTex + parallaxOffset) * _EmberColor;
            fixed4 emission = tex2D(_EmissionTex, IN.uv_EmissionTex + parallaxOffset) * _EmissionColor * _EmissionStrentgh;

            fixed4 lerpTexture = lerp(c, ember, sum);
            fixed4 lerpEmission = lerp(fixed4(0,0,0,0), emission, sum);

            o.Normal = lerp(c , UnpackNormal(tex2D(_Normal, IN.uv_Normal + parallaxOffset)) , sum);
            o.Albedo = lerpTexture.rgb;
            o.Emission = lerpEmission.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
