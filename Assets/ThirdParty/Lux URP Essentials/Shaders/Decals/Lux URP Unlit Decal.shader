Shader "Lux URP/Projection/Decal Unlit"
{
    Properties
    {
        [HeaderHelpLuxURP_URL(skzrp97i0tvt)]

        [Header(Surface Options)]
        [Space(5)]
        [Toggle(ORTHO_SUPPORT)]
        _OrthoSpport                                    ("Enable Orthographic Support", Float) = 0

        [Header(Surface Inputs)]
        [Space(5)]
        [HDR]_Color                                     ("Color", Color) = (1,1,1,1)
        [NoScaleOffset] _BaseMap                        ("Albedo (RGB) Alpha (A)", 2D) = "white" {}

        [Header(Distance Fading)]
        [Space(5)]
        [LuxLWRPDistanceFadeDrawer]
        _DistanceFade                                   ("Distance Fade Params", Vector) = (2500, 0.001, 0, 0)

        [Header(Stencil)]
        [Space(5)]
        [IntRange] _StencilRef                          ("Stencil Reference", Range (0, 255)) = 0
        [IntRange] _ReadMask                            ("    Read Mask", Range (0, 255)) = 255
        [IntRange] _WriteMask                           ("    Write Mask", Range (0, 255)) = 255
        [Enum(UnityEngine.Rendering.CompareFunction)]
        _StencilCompare                                 ("Stencil Comparison", Int) = 6

        [Header(Advanced)]
        [Space(5)]
        [Toggle(_APPLYFOG)] _ApplyFog("Enable Fog", Float) = 0.0
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "Queue" = "Transparent" // +59 smalltest to get drawn on top of transparents
        }
        Pass
        {
            Name "StandardUnlit"
            Tags{"LightMode" = "UniversalForward"}

            Stencil {
                Ref  [_StencilRef]
                ReadMask [_ReadMask]
                WriteMask [_WriteMask]
                Comp [_StencilCompare]
            }


            Blend SrcAlpha OneMinusSrcAlpha

        //  We draw backfaces to prevent clipping
            Cull Front
        //  So we have to set ZTest to always
            ZTest Always
        //  It is a decal!
            ZWrite Off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma shader_feature_local ORTHO_SUPPORT

            #pragma shader_feature_local _APPLYFOG

            // -------------------------------------
            // Lightweight Pipeline keywords

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma vertex vert
            #pragma fragment frag

            // Lighting include is needed because of GI
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"

            CBUFFER_START(UnityPerMaterial)
                half4 _Color;
                float2 _DistanceFade;
            CBUFFER_END

            #if defined(SHADER_API_GLES)
                TEXTURE2D(_CameraDepthTexture); SAMPLER(sampler_CameraDepthTexture);
            #else
                TEXTURE2D_X_FLOAT(_CameraDepthTexture);
            #endif
            float4 _CameraDepthTexture_TexelSize;
            //TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);

            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 positionCS : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO

                float4 viewRayOS : TEXCOORD0;
                float3 camPosOS : TEXCOORD1;
                float4 screenUV : TEXCOORD2;

                #if defined(_APPLYFOG)
                    float fogCoord : TEXCOORD3;
                #endif

                half fade : TEXCOORD4;
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput output = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.positionCS = TransformObjectToHClip(v.vertex.xyz);

            //  We do all calculations in Object Space
                float4 positionVS = mul(UNITY_MATRIX_MV, v.vertex);
                float3 viewRayVS = positionVS.xyz;

            //  positionVS.z here acts as view space to object space ratio (negative)
                output.viewRayOS.w = positionVS.z;
            //  NOTE: Fix direction of the viewRay
                float4x4 ViewToObjectMatrix = mul(GetWorldToObjectMatrix(), UNITY_MATRIX_I_V);
                output.viewRayOS.xyz = mul((float3x3)ViewToObjectMatrix, -viewRayVS).xyz;

                output.camPosOS = ViewToObjectMatrix._m03_m13_m23;                

            //  Get the screen uvs needed to sample the depth texture
                output.screenUV = ComputeScreenPos(output.positionCS);

                #if defined(_APPLYFOG)
                    output.fogCoord = ComputeFogFactor(output.positionCS.z);
                #endif

            //  Set distance fade value
                float3 worldInstancePos = UNITY_MATRIX_M._m03_m13_m23;
                float3 diff = (_WorldSpaceCameraPos - worldInstancePos);
                float dist = dot(diff, diff);
                output.fade = saturate( (_DistanceFade.x - dist) * _DistanceFade.y );
                
                return output;
            }

            half4 frag (VertexOutput input ) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                input.viewRayOS.xyz *= rcp(input.viewRayOS.w); // precision problem? calculating 1.0 / w in vertex shader.

                float2 uv = input.screenUV.xy / input.screenUV.w;
            //  Fix screenUV for Single Pass Stereo Rendering
                #if defined(UNITY_SINGLE_PASS_STEREO)
                    uv.x = uv.x * 0.5f + (float)unity_StereoEyeIndex * 0.5f;
                #endif

                #if defined(SHADER_API_GLES)
                    float rawDepth = SAMPLE_DEPTH_TEXTURE_LOD(_CameraDepthTexture, sampler_CameraDepthTexture, uv, 0);
                #else
                    float rawDepth = LOAD_TEXTURE2D_X(_CameraDepthTexture, _CameraDepthTexture_TexelSize.zw * uv).x;
                #endif

                float3 positionOS;

            //  Get Position in Object Space
                #if defined(ORTHO_SUPPORT)
                    UNITY_BRANCH
                    if(unity_OrthoParams.w == 1) {
                        float depthOrtho = rawDepth;
                        #if defined(UNITY_REVERSED_Z)
                        //  Needed to handle openGL
                            #if UNITY_REVERSED_Z == 1
                                depthOrtho = 1.0f - depthOrtho;
                            #endif
                        #endif
                        
                    //  Get ortho Depth
                        depthOrtho = lerp(_ProjectionParams.y, _ProjectionParams.z, depthOrtho);
                        float2 rayOrtho = -float2( unity_OrthoParams.xy * ( input.screenUV.xy - 0.5) * 2 /* to clip space */);
                        float4 vposOrtho = float4(rayOrtho, -depthOrtho, 1);

                        float3 wposOrtho = mul(unity_CameraToWorld, vposOrtho).xyz;
                        wposOrtho -= _WorldSpaceCameraPos * 2; // TODO: Why * 2 ????
                        wposOrtho *= -1;
                        float3 positionOrthoOS = mul( GetWorldToObjectMatrix(), float4(wposOrtho, 1)).xyz;
                        positionOS = positionOrthoOS;
                    }
                    else {
                    //  Get perspective Depth
                        float depth = LinearEyeDepth(rawDepth, _ZBufferParams);
                    //  Position in Object Space
                        positionOS = input.camPosOS + input.viewRayOS.xyz * depth;  
                    }
                #else
                //  Get perspective Depth
                    float depth = LinearEyeDepth(rawDepth, _ZBufferParams);
                //  Position in Object Space
                    positionOS = input.camPosOS + input.viewRayOS.xyz * depth; 
                #endif

            //  Clip decal to volume
                clip(float3(0.5, 0.5, 0.5) - abs(positionOS.xyz));

                float2 texUV = positionOS.xz + float2(0.5, 0.5);
                half4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, texUV) * _Color;
            
            //  Distance Fade
                #if defined(ORTHO_SUPPORT)
                    col.a *= ((unity_OrthoParams.w == 1.0h) ? 1.0h : input.fade);
                #else
                    col.a *= input.fade;
                #endif

                #if defined(_APPLYFOG)
                    col.rgb = MixFog(col.rgb, input.fogCoord);
                #endif

                return half4(col);
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/InternalErrorShader"
    CustomEditor "LuxURPUniversalCustomShaderGUI"
}