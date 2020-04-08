Shader "Lux Displacement/LWRP Unlit"
{
    Properties
    {
        _BaseMap("Texture", 2D) = "white" {}
        _BaseColor("Color", Color) = (1, 1, 1, 1)
        _Cutoff("AlphaCutout", Range(0.0, 1.0)) = 0.5

        // BlendMode
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("Src", Float) = 1.0
        [HideInInspector] _DstBlend("Dst", Float) = 0.0
        [HideInInspector] _ZWrite("ZWrite", Float) = 1.0
        [HideInInspector] _Cull("__cull", Float) = 2.0
        
        // Editmode props
        [HideInInspector] _QueueOffset("Queue offset", Float) = 0.0
        
        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (0.5, 0.5, 0.5, 1)
        [HideInInspector] _SampleGI("SampleGI", float) = 0.0 // needed from bakedlit
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "IgnoreProjector" = "True" "RenderPipeline" = "LightweightPipeline" }
        LOD 100

        //Blend [_SrcBlend][_DstBlend]
//Blend One One
Blend SrcAlpha OneMinusSrcAlpha // Traditional transparency
//Blend One OneMinusSrcAlpha // Premultiplied transparency
        ZWrite [_ZWrite]
        Cull [_Cull]
ZTest Off

        Pass
        {
            Name "Unlit"
            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _ALPHAPREMULTIPLY_ON

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_instancing

            //#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/SurfaceInput.hlsl"

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"

            TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_BumpMap);            SAMPLER(sampler_BumpMap);
            TEXTURE2D(_EmissionMap);        SAMPLER(sampler_EmissionMap);



            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
                half _Cutoff;
            CBUFFER_END

            //TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);

            

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 uv               : TEXCOORD0;
                half4 color             : COLOR;
// in acse we rotate
float4 tangentOS : TANGENT;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv        : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half4 color : COLOR;

float3 tangentWS : TEXCOORD1;
float3 bitangentWS : TEXCOORD2;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
output.vertex = vertexInput.positionCS;

output.tangentWS = TransformObjectToWorldDir(input.tangentOS.xyz);
real sign = input.tangentOS.w * GetOddNegativeScale();
output.bitangentWS = cross (  half3(0,1,0), output.tangentWS ) * sign;           

                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);

                output.color = input.color;
                
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                half2 uv = input.uv;
                half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
                
                //half3 color = texColor.rgb * _BaseColor.rgb * input.color.rgb;

                half3 color;
                // We handle color as a tangent space normal – which it actually is :)
                half3 normalTS = half3(texColor.rg * 2 - 1, 0);
                half3 normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, input.bitangentWS, half3(0,1,0)));
                color.rg = normalWS.rb * 0.5 + 0.5; // Compress
                color.b = 1;
half alpha = texColor.a * _BaseColor.a * input.color.a;
                
                //AlphaDiscard(alpha, _Cutoff);


                return half4(color, alpha);
            }
            ENDHLSL
        }




    }
    FallBack "Hidden/InternalErrorShader"
    //CustomEditor "UnityEditor.Rendering.LWRP.ShaderGUI.UnlitShader"
}

