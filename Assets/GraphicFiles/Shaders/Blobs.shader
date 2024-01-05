Shader "Blobs"
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

            float makePoint(float x, float y, float fx, float fy, float sx, float sy, float t)
            {
            	float xx = x + sin(t* fx) * sx;
            	float yy = y + cos(t* fy) * sy;
            	return 1.0 /sqrt(xx * xx + yy * yy);
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

                // float2 coordinateScale = (coordinateBase + 1.0 )/ (float2(2.0, 2.0));
                // float2 coordinateScale = (coordinate + 1.0 );
                float2 coordinateScale2 = (coordinateBase + 1.0 )/ float2(2.0,2.0);

    			// float2 coordinateScale = float2(scaleResolution.x + 1.0 + _rangeZero_Ten,scaleResolution.y + 1.0 + _rangeSOne_One);

                //Test Output 
                float3 col  = 0.0;
                float3 col2 = float3(coordinateBase.x + coordinateBase.y, coordinateBase.y - coordinateBase.x, pow(coordinateBase.x,2.0f));
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////
	
                col = 0.0;
                //////////////////////////////////////////////////////////////////////////////////////////////


				float x=coordinateBase.x;
				float y=coordinateBase.y;
				float time = TIME;
	
				float a=
					makePoint(x,y,3.3,2.9,0.3,0.3,time);
				a=a+makePoint(x,y,1.9,2.0,0.4,0.4,time);
				a=a+makePoint(x,y,0.8,0.7,0.4,0.5,time);
				a=a+makePoint(x,y,2.3,0.1,0.6,0.3,time);
				a=a+makePoint(x,y,0.8,1.7,0.5,0.4,time);
				a=a+makePoint(x,y,0.3,1.0,0.4,0.4,time);
				a=a+makePoint(x,y,1.4,1.7,0.4,0.5,time);
				a=a+makePoint(x,y,1.3,2.1,0.6,0.3,time);
				a=a+makePoint(x,y,1.8,1.7,0.5,0.4,time);   
				   
				// float b = 0.0;
				float b=
					   makePoint(x,y,3.3,2.9,0.3,0.3,time);
					   makePoint(x,y,1.2,1.9,0.3,0.3,time);
				b=b+makePoint(x,y,0.7,2.7,0.4,0.4,time);
				b=b+makePoint(x,y,1.4,0.6,0.4,0.5,time);
				b=b+makePoint(x,y,2.6,0.4,0.6,0.3,time);
				b=b+makePoint(x,y,0.7,1.4,0.5,0.4,time);
				b=b+makePoint(x,y,0.7,1.7,0.4,0.4,time);
				b=b+makePoint(x,y,0.8,0.5,0.4,0.5,time);
				b=b+makePoint(x,y,1.4,0.9,0.6,0.3,time);
				b=b+makePoint(x,y,0.7,1.3,0.5,0.4,time);
	
				// float c = 0.0;

				float c=
					   makePoint(x,y,3.3,2.9,0.3,0.3,time);
					   makePoint(x,y,3.7,0.3,0.3,0.3,time);
				c=c+makePoint(x,y,1.9,1.3,0.4,0.4,time);
				c=c+makePoint(x,y,0.8,0.9,0.4,0.5,time);
				c=c+makePoint(x,y,1.2,1.7,0.6,0.3,time);
				c=c+makePoint(x,y,0.3,0.6,0.5,0.4,time);
				c=c+makePoint(x,y,0.3,0.3,0.4,0.4,time);
				c=c+makePoint(x,y,1.4,0.8,0.4,0.5,time);
				c=c+makePoint(x,y,0.2,0.6,0.6,0.3,time);
				c=c+makePoint(x,y,1.3,0.5,0.5,0.4,time);

				float3 d = float3(a, b, c)/32.0;

				col = float3(d.x, d.y, d.z);




                // return float4(col, (col.x + col.y + col.z)/3.0);
                return float4(col, 1.0);


				
			}

			ENDCG
		}
	}
}

























