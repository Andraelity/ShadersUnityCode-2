Shader "FlameAndFire"
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


			float noise(float3 p) //Thx to Las^Mercury
			{
				float3 i = floor(p);
				float4 a = dot(i, float3(1.0, 57.0, 21.)) + float4(0.0, 57.0, 21.0, 78.0);
				float3 f = cos((p-i)*acos(-1.0))*(-0.5)+0.5;
				a = lerp(sin(cos(a)*a),sin(cos(1.0 + a) * (1.0 + a )), f.x);

				a.xy = lerp(a.xz, a.yw, f.y);
				return lerp(a.x, a.y, f.z);
			}
			
			float sphere(float3 p, float4 spr)
			{
				return length(spr.xyz-p) - spr.w;
			}
			
			float flame(float3 p)
			{
				float d =  sphere(p * float3(1.0, 0.5, 1.0), float4(0.0, -1.0, 0.0, 1.0));
				return d + (noise(p + float3(0.0,TIME * 2.0 ,0.0)) + noise(p * 3.0) * 0.5) * 0.25 * (p.y);
			}
			
			float scene(float3 p)
			{
				return min(100.0 -length(p) , abs(flame(p)) );
			}

			float4 raymarch(float3 org, float3 dir)
			{
				float d = 0.0, glow = 0.0, eps = 0.02;
				float3  p = org;
				bool glowed = false;
				
				for(int i=0; i<64; i++)
				{
					d = scene(p) + eps;
					p += d * dir;
					if( d>eps )
					{
						if(flame(p) < .0)
							glowed=true;
						if(glowed)
			       			glow = float(i)/64.;
					}
				}
				return float4(p,glow);
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
                

                float2 coordinate = i.uv;

				float2 scaleResolution = i.uv /float2(2, 2);
                // float2 scaleResolution = i.uv /float2(2, 2);

                // float2 coordinateScale = (coordinateBase + 1.0 )/ (float2(2.0, 2.0));
                // float2 coordinateScale = (coordinate + 1.0 );
                float2 coordinateScale2 = (coordinate + 1.0 )/ float2(2.0,2.0);

    			// float2 coordinateScale = float2(scaleResolution.x + 1.0 + _rangeZero_Ten,scaleResolution.y + 1.0 + _rangeSOne_One);

                //Test Output 
                float3 col  = 0.0;
                float3 col2 = float3(coordinate.x + coordinate.y, coordinate.y - coordinate.x, pow(coordinate.x,2.0f));
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////
	
                col = 0.0;
                //////////////////////////////////////////////////////////////////////////////////////////////

                	
                float3 org = float3(0.0, -2.0, 4.0);

                float3 dir = normalize(float3(coordinate.x * 1.6, -coordinate.y, -1.5));

                float4 p = raymarch(org, dir);

                float glow = p.w;

                float4 colHand = 0.0;
                colHand = lerp(float4(1.0, 0.5, 0.1, 1.0), float4(0.1, 0.5, 1.0, 1.0), p.y * 0.02 + 0.4);

                float4 colOut = lerp(float4(0.0, 0.0, 0.0, 0.0), colHand, pow(glow * 2.0, 4.0));

                return float4(colOut.xyz, 1.0);


				
			}

			ENDCG
		}
	}
}

























