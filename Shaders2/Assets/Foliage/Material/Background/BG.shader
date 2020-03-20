Shader "Unlit/BG"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorA("_ColorA", Color) = (1,1,1,1)
        _ColorB("_ColorB", Color) = (1,1,1,1)
        _ColorOffset("_ColorOffset", Float) = 0
    }

    SubShader
        {
          Tags { "RenderType" = "Opaque" }
          CGPROGRAM
          #pragma surface surf Lambert

          struct Input 
          {
	        float2 uv_MainTex;
            float4 screenPos;
          };

          sampler2D _MainTex;
          fixed4 _ColorA;
          fixed4 _ColorB;
          half _ColorOffset;

          void surf(Input IN, inout SurfaceOutput o) 
          {
              float2 screenUV = IN.screenPos.xy / IN.screenPos.w;

                fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * lerp(_ColorA, _ColorB , screenUV.y + _ColorOffset);
                o.Albedo = c.rgb;
                o.Alpha = c.a;
          }
          ENDCG
    }
    Fallback "Diffuse"
}
