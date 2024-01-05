Shader "NoiseBump"
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

            float3x3 m = {0.00, 0.80, 0.60, -0.80, 0.36, -0.48, -0.60, -0.48, 0.64};


            float hash(float n)
            {
                return frac(sin(n) * 43758.5453);
            }

            float noise(in float3 x)
            {
                float3 p = floor(x);
                float3 f = frac(x);

                f = f * f * (3.0 - 2.0 * f);

                float n = p.x  + p.y * 57.0 + 113.0 * p.z;

                float res = lerp(
                                lerp(
                                    lerp(hash(n +  0.0),  hash(n + 1.0), f.x), 
                                    lerp(hash(n + 57.0),  hash(n + 58.0), f.x), 
                                    f.y), 
                                lerp(
                                    lerp(hash(n + 113.0),  hash(n + 114.0), f.x), 
                                    lerp(hash(n + 170.0),  hash(n + 171.0), f.x), 
                                    f.y), 
                                f.z);

                return res;
            }

            float fbm(float3 p)
            {
                float f = 0.0;

                f += 0.5000 * noise(p);
                p = mul(m,p * 2.02);
                f += 0.2500 * noise(p);
                p = mul(m,p * 2.03);
                f += 0.1250 * noise(p);
                p = mul(m,p * 2.01);
                f += 0.0625 * noise(p);

                return f/0.9375;

            }

            float3 colFunc(float inGray, float3 inColor)
            {

                return lerp(
                            (lerp(float3(0.0, 0.0, 0.0), inColor, inGray * 2.0)),
                            (lerp(inColor, float3(1.0, 1.0, 1.0), (inGray - 0.5) * 2.0)), 
                             step(0.5, inGray));
            }

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

                float2 coordinateBase = i.uv;

                float2 coordinate = i.uv/float2(2,2);

				float2 scaleResolution = i.uv /float2(2, 2);
                // float2 scaleResolution = i.uv /float2(2, 2);

                float2 coordinateScale = (coordinateBase + 1.0 )/ (float2(2.0, 2.0));

    			// float2 coordinateScale = float2(scaleResolution.x + 1.0 + _rangeZero_Ten,scaleResolution.y + 1.0 + _rangeSOne_One);


                //Test Output 
                float3 col = 0.0;
                float3 col2 = float3(coordinateBase.x + coordinateBase.y, coordinateBase.y - coordinateBase.x, pow(coordinateBase.x,2.0f));
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////
	
                col = 0.0;
                //////////////////////////////////////////////////////////////////////////////////////////////


                float pulse = smoothstep(0.95, 1.0, abs(sin(TIME)));

                float2 uv = coordinateScale;

                float n1 = fbm(float3((uv.xy * 12.0) + (TIME * 0.1), 0.0));

                float n2 = fbm(float3((uv.xy * 8.0) - (TIME * 0.83), 0.0));

                // float n21 = fbm(float3((uv.xy * 16.0) - (TIME * 0.03), 0.0));

                float edge1 = (abs(sin(TIME * 0.1)) * 0.05) + 0.45;
                float edge2 = lerp(0.5, 0.5 + (sin(TIME *30.0) * 0.01), pulse);

                float msk1 = smoothstep(edge1, edge1 + 0.1, n1);
                float msk2 = smoothstep(edge2, edge2 + 0.1, n2);

                n1 = n1 * msk1;
                n2 = n2 * msk2;

                float3 c1 = colFunc(n1 * 0.35, float3(0.7, 1.0, 0.4)) * n1;
                float3 c2 = colFunc(n1 * 0.65, float3(0.6, 1.0, 0.1)) * n2;

                float3 c3 = lerp(c1, c2, msk2);



                return float4(c3, 1.0);


				
			}

			ENDCG
		}
	}
}

























