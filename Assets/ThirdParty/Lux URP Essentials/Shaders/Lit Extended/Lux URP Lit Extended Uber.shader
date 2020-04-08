﻿Shader "Lux URP/Lit Extended Uber"
{
    Properties
    {
        [Header(Surface Options)]
        [Space(5)]

        [Enum(UnityEngine.Rendering.CompareFunction)]
        _ZTest                              ("ZTest", Int) = 4
        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull                               ("Culling", Float) = 2
        [Toggle(_ALPHATEST_ON)]
        _AlphaClip                          ("Alpha Clipping", Float) = 0.0
        _Cutoff                             ("     Threshold", Range(0.0, 1.0)) = 0.5
        [Toggle(_FADING_ON)]
        _CameraFadingEnabled                ("     Enable Camera Fading", Float) = 0.0
        _CameraFadeDist                     ("     Fade Distance", Float) = 1.0
        [Toggle(_FADING_SHADOWS_ON)]
        _CameraFadeShadows                  ("     Fade Shadows", Float) = 0.0
        _CameraShadowFadeDist               ("     Shadow Fade Distance", Float) = 1.0
        [ToggleOff(_RECEIVE_SHADOWS_OFF)]
        _ReceiveShadows                     ("Receive Shadows", Float) = 1.0

       
        [Header(Surface Inputs)]
        [Space(5)]
        [MainTexture] _BaseMap              ("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor              ("Color", Color) = (0.5,0.5,0.5,1)

        [Space(5)]
        [Toggle(_NORMALMAP)]
        _EnableNormal                       ("Enable Normal Map", Float) = 0
        [NoScaleOffset] _BumpMap            ("     Normal Map", 2D) = "bump" {}
        _BumpScale                          ("     Normal Scale", Float) = 1.0


        [Toggle(_BENTNORMAL)]
        _EnableBentNormal ("Enable Bent Normal Map", Float) = 0
        _BentNormalMap                         ("Bent Normal Map", 2D) = "bump" {}

        [Space(5)]
        [Toggle(_PARALLAX)]
        _EnableParallax                     ("Enable Height Map", Float) = 0
        [NoScaleOffset] _HeightMap          ("     Height Map (G)", 2D) = "black" {}
        _Parallax                           ("     Extrusion", Range (0.0, 0.1)) = 0.02
        [Toggle(_PARALLAXSHADOWS)]
        _EnableParallaxShadows              ("Enable Parallax Shadows", Float) = 0

        [Space(5)]
        [Toggle(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)]
        _SmoothnessTextureChannel           ("Sample Smoothness from Albedo Alpha", Float) = 0
        _Smoothness                         ("Smoothness", Range(0.0, 1.0)) = 0.5

        [Header(Work Flow)]

        [Space(5)]
        [NoScaleOffset] _SpecGlossMap       ("Specular Map", 2D) = "white" {}
        _SpecColor                          ("Specular Color", Color) = (0.2, 0.2, 0.2) // Order of props important for editor!?

        [ToggleOff(_SPECULAR_SETUP)]  
        _WorkflowMode                       ("Metal Workflow", Float) = 1.0
        [Space(5)]
        [NoScaleOffset] _MetallicGlossMap   ("     Metallic Map", 2D) = "white" {}  // Order of props important for editor!?
        [Gamma] _Metallic                   ("     Metallic", Range(0.0, 1.0)) = 0.0

        [Space(5)]
        [Toggle(_METALLICSPECGLOSSMAP)] 
        _EnableMetalSpec                    ("Enable Spec/Metal Map", Float) = 0.0

        [Header(Additional Maps)]
        [Space(10)]
        [Toggle(_OCCLUSIONMAP)] 
        _EnableOcclusion                    ("Enable Occlusion", Float) = 0.0
        [NoScaleOffset] _OcclusionMap       ("     Occlusion Map", 2D) = "white" {}
        _OcclusionStrength                  ("     Occlusion Strength", Range(0.0, 1.0)) = 1.0

        [Space(5)]
        [Toggle(_EMISSION)] 
        _Emission                           ("Enable Emission", Float) = 0.0
        _EmissionColor                      ("     Color", Color) = (0,0,0)
        [NoScaleOffset] _EmissionMap        ("     Emission", 2D) = "white" {}


        [Header(Rim Lighting)]
        [Space(5)]
        [HideInInspector] _Dummy("Dummy", Float) = 0.0 // needed by custum inspector
        
        [Toggle(_RIMLIGHTING)]
        _Rim                                ("Enable Rim Lighting", Float) = 0
        [HDR] _RimColor                     ("Rim Color", Color) = (0.5,0.5,0.5,1)
        _RimPower                           ("Rim Power", Float) = 2
        _RimFrequency                       ("Rim Frequency", Float) = 0
        _RimMinPower                        ("     Rim Min Power", Float) = 1
        _RimPerPositionFrequency            ("     Rim Per Position Frequency", Range(0.0, 1.0)) = 1

        
        //[Header(Stencil)]
        //[Space(5)]

        [IntRange] _Stencil                 ("Stencil Reference", Range (0, 255)) = 0
        [IntRange] _ReadMask                ("     Read Mask", Range (0, 255)) = 255
        [IntRange] _WriteMask               ("     Write Mask", Range (0, 255)) = 255
        [Enum(UnityEngine.Rendering.CompareFunction)]
        _StencilComp                        ("Stencil Comparison", Int) = 8     // always – terrain should be the first thing being rendered anyway
        [Enum(UnityEngine.Rendering.StencilOp)]
        _StencilOp                          ("Stencil Operation", Int) = 0      // 0 = keep, 2 = replace
        [Enum(UnityEngine.Rendering.StencilOp)]
        _StencilFail                        ("Stencil Fail Op", Int) = 0           // 0 = keep
        [Enum(UnityEngine.Rendering.StencilOp)] 
        _StencilZFail                       ("Stencil ZFail Op", Int) = 0          // 0 = keep


        [Header(Advanced)]
        [Space(5)]

        [Toggle(_ENABLE_GEOMETRIC_SPECULAR_AA)]
        _GeometricSpecularAA                ("Geometric Specular AA", Float) = 0.0
        _ScreenSpaceVariance                ("     Screen Space Variance", Range(0.0, 1.0)) = 0.1
        _SAAThreshold                       ("     Threshold", Range(0.0, 1.0)) = 0.2

        [Space(5)]
        [Toggle(_ENABLE_AO_FROM_GI)]
        _AOfromGI                           ("Get ambient specular Occlusion from GI", Float) = 0.0
        _GItoAO                             ("     GI to AO Factor", Float) = 10
        _GItoAOBias                         ("     GI to AO Bias", Range(0,1)) = 0.0

        _HorizonOcclusion                   ("Horizon Occlusion", Range(0,1)) = 0.5

        [Space(5)]
        [ToggleOff]
        _SpecularHighlights                 ("Specular Highlights", Float) = 1.0
        [ToggleOff]
        _EnvironmentReflections             ("Environment Reflections", Float) = 1.0
        
        // Blending state
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
//[HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
//[HideInInspector] _Cull("__cull", Float) = 2.0

// _ReceiveShadows("Receive Shadows", Float) = 1.0        
        // Editmode props
        [HideInInspector] _QueueOffset("Queue offset", Float) = 0.0
        
        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _GlossMapScale("Smoothness", Float) = 0.0
        [HideInInspector] _Glossiness("Smoothness", Float) = 0.0
        [HideInInspector] _GlossyReflections("EnvironmentReflections", Float) = 0.0

        // GUI
        [HideInInspector] _FoldSurfaceOptions("Surface Options", Float) = 0.0
        [HideInInspector] _FoldSurfaceInputs("Surface Inputs", Float) = 1.0
        [HideInInspector] _FoldAdvancedSurfaceInputs("Advanced Surface Inputs", Float) = 1.0
        [HideInInspector] _FoldRimLightingInputs("Rim Lighting Options", Float) = 0.0
        [HideInInspector] _FoldStencilOptions("Stencil Options", Float) = 0.0
        [HideInInspector] _FoldAdvanced("Advanced", Float) = 0.0
    }

    SubShader
    {
        // Lightweight Pipeline tag is required. If Lightweight render pipeline is not set in the graphics settings
        // this Subshader will fail. One can add a subshader below or fallback to Standard built-in to make this
        // material work with both Lightweight Render Pipeline and Builtin Unity Pipeline
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}
        LOD 300

        // ------------------------------------------------------------------
        //  Forward pass. Shades all light in a single pass. GI + emission + Fog
        Pass
        {
            // Lightmode matches the ShaderPassName set in LightweightRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Lightweight Render Pipeline
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            Stencil {
                Ref   [_Stencil]
                ReadMask [_ReadMask]
                WriteMask [_WriteMask]
                Comp  [_StencilComp]
                Pass  [_StencilOp]
                Fail  [_StencilFail]
                ZFail [_StencilZFail]
                //replace
            }

            Blend[_SrcBlend][_DstBlend]
            ZTest [_ZTest]
            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard SRP library
            // All shaders must be compiled with HLSLcc and currently only gles is not using HLSLcc by default
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords

            #define _UBER

            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _SAMPLENORMAL

            #pragma shader_feature_local _PARALLAX
            #pragma shader_feature_local _BENTNORMAL

            #pragma shader_feature_local _ENABLE_GEOMETRIC_SPECULAR_AA
            #pragma shader_feature_local _ENABLE_AO_FROM_GI

            #pragma shader_feature_local _RIMLIGHTING

            #pragma shader_feature_local _FADING_ON

            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION            
            #pragma shader_feature _METALLICSPECGLOSSMAP
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _OCCLUSIONMAP
            
            #pragma shader_feature _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature _SPECULAR_SETUP
            #pragma shader_feature _RECEIVE_SHADOWS_OFF

            // -------------------------------------
            // Lightweight Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma vertex LitPassVertexUber
            #pragma fragment LitPassFragmentUber

            #include "Includes/Lux URP Lit Extended Inputs.hlsl"
            #include "Includes/Lux URP Uber Lit Pass.hlsl"

            #include "Includes/Lux URP Lit Extended Lighting.hlsl"



            half4 LitPassFragmentUber(Varyings input, half facing : VFACE) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                //  Camera Fading
                #if defined(_ALPHATEST_ON) && defined(_FADING_ON)
                /*  not needed as we go with positionCS
                //  shadowcoords are screenpos
                    #if SHADOWS_SCREEN
                        #if defined(_MAIN_LIGHT_SHADOWS) && !defined(_RECEIVE_SHADOWS_OFF)
                            float4 screenPos = input.shadowCoord;
                        #endif
                //  Get screenpos
                    #else
                        float4 screenPos = input.screenCoord;
                    #endif
                */
                    clip ( input.positionCS.w - _CameraFadeDist - Dither32(input.positionCS.xy, 1));                   
                    //clip ( input.positionCS.w - _CameraFadeDist - Dither32(screenPos.xy / screenPos.w * _ScreenParams.xy, 1));
                    //clip ( input.positionCS.w - _CameraFadeDist - Dither5(screenPos.xy / screenPos.w * _ScreenParams.xy + float2(0.5, -0.5), 1));
                #endif

                #if defined(_PARALLAX)
            //  NOTE: Take possible back faces into account.
                    input.normalWS.xyz *= facing;

                    half3x3 tangentSpaceRotation =  half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
                    half3 viewDirWS = half3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
                    half3 viewDirTS = SafeNormalize( mul(tangentSpaceRotation, viewDirWS) );
                #else
                    half3 viewDirTS = 0; 
                #endif

                SurfaceData surfaceData;
                InitializeStandardLitSurfaceDataUber(input.uv, viewDirTS, surfaceData);

                InputData inputData;
                InitializeInputData(input, surfaceData.normalTS, inputData);

                #if defined(_BENTNORMAL)
                    half3 bentNormal  = SampleNormalExtended(input.uv, TEXTURE2D_ARGS(_BentNormalMap, sampler_BentNormalMap), 1);     
                    #if defined(_SAMPLENORMAL)
                        bentNormal = normalize(half3(bentNormal.xy + surfaceData.normalTS.xy, bentNormal.z*surfaceData.normalTS.z));
                    #endif
                    bentNormal = TransformTangentToWorld(bentNormal, half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
                    //bentNormal = mul(GetObjectToWorldMatrix(), float4(bentNormal, 0) );
                    bentNormal = NormalizeNormalPerPixel(bentNormal);
                    #if !defined(LIGHTMAP_ON)
                        inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, bentNormal);
                    #endif
                #endif

                #if defined(_ENABLE_GEOMETRIC_SPECULAR_AA)
                    half3 worldNormalFace = input.normalWS.xyz;
                    half roughness = 1.0h - surfaceData.smoothness;
                    //roughness *= roughness; // as in Core?
                    half3 deltaU = ddx( worldNormalFace );
                    half3 deltaV = ddy( worldNormalFace );
                    half variance = _ScreenSpaceVariance * ( dot(deltaU, deltaU) + dot(deltaV, deltaV) );
                    half kernelSquaredRoughness = min( 2.0h * variance , _SAAThreshold );
                    half squaredRoughness = saturate( roughness * roughness + kernelSquaredRoughness );
                    surfaceData.smoothness = 1.0h - sqrt(squaredRoughness);
                #endif

                #if defined(_RIMLIGHTING)
                    half rim = saturate(1.0h - saturate( dot(inputData.normalWS, inputData.viewDirectionWS ) ) );
                    half power = _RimPower;
                    UNITY_BRANCH if(_RimFrequency > 0 ) {
                        half perPosition = lerp(0.0h, 1.0h, dot(1.0h, frac(UNITY_MATRIX_M._m03_m13_m23) * 2.0h - 1.0h ) * _RimPerPositionFrequency ) * 3.1416h;
                        power = lerp(power, _RimMinPower, (1.0h + sin(_Time.y * _RimFrequency + perPosition) ) * 0.5h );
                    }
                    surfaceData.emission += pow(rim, power) * _RimColor.rgb * _RimColor.a;
                #endif

                //half4 color = LightweightFragmentPBR(inputData, surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.occlusion, surfaceData.emission, surfaceData.alpha);

                half4 color = LuxExtended_UniversalFragmentPBR(inputData, surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.occlusion, surfaceData.emission, surfaceData.alpha,
                    #if defined(_ENABLE_AO_FROM_GI)
                        _GItoAO, _GItoAOBias,
                    #else
                        1, 0,
                    #endif
                    #if defined(_BENTNORMAL)
                        bentNormal,
                    #else
                        half3(0,0,0),
                    #endif
                    input.normalWS.xyz,
                    _HorizonOcclusion
                );

                color.rgb = MixFog(color.rgb, inputData.fogCoord);

// Preview Spec AA
// color.rgb = surfaceData.smoothness;

// Preview Visibility from Bent Normal
// color.rgb = dot(inputData.normalWS, bentNormal); // * 0.5 + 0.5;

                return color;
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            //ZTest LEqual
            ZTest [_ZTest]
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //#pragma shader_feature _NORMALMAP
            #pragma shader_feature_local _PARALLAXSHADOWS
            #pragma shader_feature_local _FADING_SHADOWS_ON

            #if defined (_PARALLAXSHADOWS) && !defined(_NORMALMAP)
                #define _NORMALMAP
            #endif

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Includes/Lux URP Lit Extended Inputs.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            
            float3 _LightDirection;

            VertexOutput ShadowPassVertex(VertexInput input)
            {
                VertexOutput output = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                //float3 normalWS = TransformObjectToWorldDir(input.normalOS);

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                #if defined(_ALPHATEST_ON)
                    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                    #if defined(_PARALLAXSHADOWS)
                        //half3x3 tangentSpaceRotation =  half3x3(normalInput.tangentWS, normalInput.bitangentWS, normalInput.normalWS);
                        half3 viewDirWS = GetCameraPositionWS() - positionWS;
                        //output.viewDirTS = SafeNormalize( mul(tangentSpaceRotation, viewDirWS) );
                        output.normalWS = half4(normalInput.normalWS, viewDirWS.x);
                        output.tangentWS = half4(normalInput.tangentWS, viewDirWS.y);
                        output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.z);
                    #endif
                #endif

            //  When rendering backfaces normal extrusion is in the wrong direction...
                float facingNormal = dot(normalInput.normalWS, _LightDirection);

                output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, sign(facingNormal) * normalInput.normalWS, _LightDirection));
                #if UNITY_REVERSED_Z
                    output.positionCS.z = min(output.positionCS.z, output.positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #else
                    output.positionCS.z = max(output.positionCS.z, output.positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #endif

                #if defined(_ALPHATEST_ON) && defined(_FADING_SHADOWS_ON)
                    //output.screenPos = ComputeScreenPos(output.positionCS);
                    //output.screenPos.z = distance(positionWS, GetCameraPositionWS() );
                    output.screenPos = distance(positionWS, GetCameraPositionWS() );
                #endif

                return output;
            }

            half4 ShadowPassFragment(VertexOutput input, half facing : VFACE) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                #if defined(_ALPHATEST_ON)
                //  Camera Fade
                    #if defined(_FADING_SHADOWS_ON)
                        //float4 screenPos = input.screenPos;
                        //clip ( screenPos.z - _CameraShadowFadeDist - Dither32(screenPos.xy / screenPos.w * _ScreenParams.xy, 1));
                        clip ( input.screenPos - _CameraShadowFadeDist - Dither32(input.positionCS.xy, 1));
                    #endif

                    float2 uv = input.uv;

                //  Parallax
                    #if defined(_PARALLAXSHADOWS)
                    //  When it comes to shadows we can calculate the proper viewdirWS only for directional lights
                    //  So all other lights will simply skip parallax extrusion
                        float isDirectinalLight = UNITY_MATRIX_VP._m33;
                        
                    //    UNITY_BRANCH
                    //    if(isDirectinalLight == 1) {
                            input.normalWS.xyz *= facing;
                            half3x3 tangentSpaceRotation =  half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
                            //half3 viewDirWS = half3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
                        
                        //  viewDirWS in case of the directional light equals cam forward
                            half3 viewDirWS = UNITY_MATRIX_V[2].xyz;

                            half3 viewDirTS = SafeNormalize( mul(tangentSpaceRotation, viewDirWS) );
                            float3 v = SafeNormalize(viewDirTS); //input.viewDirTS);
                            v.z += 0.42;
                            v.xy /= v.z;
                            float halfParallax = _Parallax * 0.5f;
                            float parallax = SAMPLE_TEXTURE2D(_HeightMap, sampler_HeightMap, uv).g * _Parallax - halfParallax;
                            float2 offset1 = parallax * v.xy;
                        //  Calculate 2nd height
                            parallax = SAMPLE_TEXTURE2D(_HeightMap, sampler_HeightMap, uv + offset1).g * _Parallax - halfParallax;
                            float2 offset2 = parallax * v.xy;
                        //  Final UVs
                            uv += (offset1 + offset2) * 0.5f;
                        //}
                    #endif

                    half alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).a * _BaseColor.a;
                    clip (alpha - _Cutoff);
                #endif
                return 0;
            }

            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ZTest [_ZTest]
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //#pragma shader_feature _NORMALMAP
            #pragma shader_feature_local _PARALLAX
            #pragma shader_feature_local _FADING_ON

            #if defined (_PARALLAX) && !defined(_NORMALMAP)
                #define _NORMALMAP
            #endif

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #include "Includes/Lux URP Lit Extended Inputs.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"

            VertexOutput DepthOnlyVertex(VertexInput input)
            {
                VertexOutput output = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(positionWS);

                #if defined(_ALPHATEST_ON)

                    //#if defined(_FADING_ON)
                    //    output.screenPos = ComputeScreenPos(output.positionCS);
                    //#endif

                    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

                    #if defined(_PARALLAX)
                        VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                        //half3x3 tangentSpaceRotation =  half3x3(normalInput.tangentWS, normalInput.bitangentWS, normalInput.normalWS);
                    //  was half3 - but output is float?! lets add normalize here - not: it breks the regular pass...
                        half3 viewDirWS = GetCameraPositionWS() - positionWS;
                        //output.viewDirTS = SafeNormalize( mul(tangentSpaceRotation, viewDirWS) );
                        output.normalWS = half4(normalInput.normalWS, viewDirWS.x);
                        output.tangentWS = half4(normalInput.tangentWS, viewDirWS.y);
                        output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.z);
                    #endif
                #endif

                return output;
            }

            half4 DepthOnlyFragment(VertexOutput input) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                #if defined(_ALPHATEST_ON)

                    #if defined(_FADING_ON)
                        //float4 screenPos = input.screenPos;
                        clip ( input.positionCS.w - _CameraFadeDist - Dither32(input.positionCS.xy, 1));
                        //clip ( input.positionCS.w - _CameraFadeDist - Dither32(screenPos.xy / screenPos.w * _ScreenParams.xy, 1));
                    #endif

                    float2 uv = input.uv;

                    #if defined(_PARALLAX)
                
                    //  Parallax
                        half3x3 tangentSpaceRotation =  half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
                        half3 viewDirWS = half3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
                        half3 viewDirTS = SafeNormalize( mul(tangentSpaceRotation, viewDirWS) );

                        float3 v = SafeNormalize(viewDirTS);
                        v.z += 0.42;
                        v.xy /= v.z;
                        float halfParallax = _Parallax * 0.5f;
                        float parallax = SAMPLE_TEXTURE2D(_HeightMap, sampler_HeightMap, uv).g * _Parallax - halfParallax;
                        float2 offset1 = parallax * v.xy;
                    //  Calculate 2nd height
                        parallax = SAMPLE_TEXTURE2D(_HeightMap, sampler_HeightMap, uv + offset1).g * _Parallax - halfParallax;
                        float2 offset2 = parallax * v.xy;
                    //  Final UVs
                        uv += (offset1 + offset2) * 0.5f;
                    #endif

                    half alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).a * _BaseColor.a;
                    clip (alpha - _Cutoff);
                #endif

                return 0;
            }

            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
        Pass
        {
            Name "Meta"
            Tags{"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMeta

            #define _PARALLAX

            #pragma shader_feature _SPECULAR_SETUP
            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICSPECGLOSSMAP
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #pragma shader_feature _SPECGLOSSMAP

            #include "Includes/Lux URP Lit Extended Inputs.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitMetaPass.hlsl"

            ENDHLSL
        }

    }
    FallBack "Hidden/InternalErrorShader"
    CustomEditor "LuxUberShaderGUI"
}