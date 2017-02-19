//  Created by Jafar Abdulrasoul

// Special thanks to Dan http://danjohnmoran.com


Shader "Effects/TransitionShaderWithTexture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {} //Main Texture, leave empty
		_TranTex ("Transition Texture", 2D) = "black" {} //Transition texture. Leave blank if using color
		_PatternTex ("Pattern Texture", 2d) = "white" {} //The pattern transition texture
		_Cutoff("Progress", Range (0, 1)) = 0 //Cut off slider
		_Color("Color", Color) = (0,0,0,0) //defaults to black
		[MaterialToggle] _UseColor("Use Color", Float) = 0 //color or texture toggle
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _TranTex;
			sampler2D _PatternTex;
			float _Cutoff;
			fixed4 _Color;
			float _UseColor;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				o.uv1 = v.uv;

				//because shaders are complicated, this adjusts coordinates
				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
					o.uv1.y = 1 - o.uv1.y;
				#endif

				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 transit = tex2D(_PatternTex, i.uv);
				//checks the blue attribute of the pattern and cuts off in respect to that
				if(transit.b < _Cutoff){
					// if _UseColor is enabled, use color instead
					if(_UseColor > 0)
						return _Color;
					// _Use color is not enabled, use the _TranTex
					return tex2D(_TranTex, i.uv);
				}
				// return the original texture aka don't do anything
				return tex2D(_MainTex, i.uv);
			}
			ENDCG
		}
	}
}
