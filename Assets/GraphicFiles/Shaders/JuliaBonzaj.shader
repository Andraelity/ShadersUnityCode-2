Shader "JuliaBonzaj"
{
	Properties
	{
		_TextureChannel0 ("Texture", 2D) = "gray" {}
		_TextureChannel1 ("Texture", 2D) = "gray" {}
		_TextureChannel2 ("Texture", 2D) = "gray" {}
		_TextureChannel3 ("Texture", 2D) = "gray" {}


	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" "DisableBatching" ="true" }
		LOD 100

		Pass
		{
		    ZWrite Off
		    Cull off
		    Blend SrcAlpha OneMinusSrcAlpha
		    
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
                  #pragma multi_compile_instancing
			
			#include "UnityCG.cginc"

			struct vertexPoints
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
                  UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct pixel
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

                  UNITY_INSTANCING_BUFFER_START(CommonProps)
                  UNITY_DEFINE_INSTANCED_PROP(fixed4, _FillColor)
                  UNITY_DEFINE_INSTANCED_PROP(float, _AASmoothing)
                  UNITY_DEFINE_INSTANCED_PROP(float, _rangeZero_Ten)
                  UNITY_DEFINE_INSTANCED_PROP(float, _rangeSOne_One)
                  UNITY_DEFINE_INSTANCED_PROP(float, _rangeZoro_OneH)
                  UNITY_DEFINE_INSTANCED_PROP(float, _mousePosition_x)
                  UNITY_DEFINE_INSTANCED_PROP(float, _mousePosition_y)

                  UNITY_INSTANCING_BUFFER_END(CommonProps)

            

			pixel vert (vertexPoints v)
			{
				pixel o;
				
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.vertex.xy;
				return o;
			}
            
                sampler2D _TextureChannel0;
                sampler2D _TextureChannel1;
                sampler2D _TextureChannel2;
                sampler2D _TextureChannel3;
      			
                #define PI 3.1415927
                #define TIME _Time.y
      
                float2 mouseCoordinateFunc(float x, float y)
                {
                	return normalize(float2(x,y));
                }
            /////////////////////////////////////////////////////////////////////////////////////////////
            // Default 
            /////////////////////////////////////////////////////////////////////////////////////////////

            fixed4 frag (pixel i) : SV_Target
			{
				
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////

			    UNITY_SETUP_INSTANCE_ID(i);
			    
		    	float aaSmoothing = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _AASmoothing);
			    fixed4 fillColor = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _FillColor);
			   	float _rangeZero_Ten = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeZero_Ten);
				float _rangeSOne_One = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeSOne_One);
			    float _rangeZoro_OneH = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeZoro_OneH);
                float _mousePosition_x = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _mousePosition_x);
                float _mousePosition_y = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _mousePosition_y);

                float2 mouseCoordinate = mouseCoordinateFunc(_mousePosition_x, _mousePosition_y);

                float2 mouseCoordinateScale = (mouseCoordinate + 1.0)/ float2(2.0,2.0);
                float2 coordinateBase = i.uv;

                float2 coordinate = i.uv/float2(2,2);

				float2 scaleResolution = i.uv /float2(2, 2);
                // float2 scaleResolution = i.uv /float2(2, 2);

                float2 coordinateScale = (coordinateBase + 1.0 )/ float2(4.0,2.0);

                // float2 coordinateScale = (coordinateBase + 1.0 )/ float2(2.0,2.0);

    			// float2 coordinateScale = float2(scaleResolution.x + 1.0 + _rangeZero_Ten,scaleResolution.y + 1.0 + _rangeSOne_One);

                //Test Output 
                float3 col  = 0.0;
                float3 col2 = float3(coordinateBase.x + coordinateBase.y, coordinateBase.y - coordinateBase.x, pow(coordinateBase.x,2.0f));
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////
	
                col = 0.0;
                //////////////////////////////////////////////////////////////////////////////////////////////


                float2 cc = 1.1 * float2(0.5 * cos(0.1 * TIME) - 0.25 * cos(0.2 * TIME),
                						 0.5 * sin(0.1 * TIME) - 0.25 * sin(0.2 * TIME));


                float4 dmin = 1000.0;

                float2 z = (-1.0 + 1.0 * coordinateScale) * float2(0.6, 0.3);
                for(int i = 0; i < 64; i++)
                {
                	z = cc + float2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y);
                	z += 0.15 * sin(float(i));
                	dmin = min(dmin, float4(abs(0.0 + z.y + 0.2 * sin(z.x)),
                							abs(1.0 + z.x + 0.5 * sin(z.y)),
                							dot(z,z),
                							length(frac(z) - 0.2)));
                }

                float3 color = dmin.w;

                color = lerp(color, float3(0.80, 0.40, 0.20), 		min(1.0, pow(dmin.x * 0.25, 0.20)));
                color = lerp(color, float3(0.12, 0.70, 0.60), 		min(1.0, pow(dmin.y * 0.50, 0.50)));
                color = lerp(color, float3(0.90, 0.40, 0.20), 1.0 - min(1.0, pow(dmin.z * 1.00, 0.15)));

                color = 1.25 * color * color;

                color *= 0.5 + 0.5 * pow(4.0 * coordinateScale.x * (1.0 - coordinateScale.y) * coordinateScale.y * (1.0 - coordinateScale.y), 0.15);



                return float4(color, 1.0);


				
			}

			ENDCG
		}
	}
}

























