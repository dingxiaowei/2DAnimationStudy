﻿// Shader uses custom editor to set double sided GI
// Needs _Culling to be set properly

// HDRP Cloth remaps smoothnes to 0-0.6 if cotton woll is enabled

Shader "Lux URP/Cloth"
{
    Properties
    {
        [HeaderHelpLuxURP_URL(kg40d8bgwewa)]

        [Header(Surface Options)]
        [Space(5)]
        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull                       ("Culling", Float) = 2
        [Toggle(_ALPHATEST_ON)]
        _AlphaClip                  ("Alpha Clipping", Float) = 0.0
        [LuxURPHelpDrawer]
        _Help ("Enabling Alpha Clipping needs you to enable and assign the Mask Map as well.", Float) = 0.0
        _Cutoff                     ("    Threshold", Range(0.0, 1.0)) = 0.5
        [ToggleOff(_RECEIVE_SHADOWS_OFF)]
        _ReceiveShadows             ("Receive Shadows", Float) = 1.0
        _ShadowOffset               ("Shadow Offset", Float) = 1.0


        [Header(Charlie Sheen Lighting)]
        [Space(5)]
        [Toggle(_COTTONWOOL)]
        _UseCottonWool              ("Enable Charlie Sheen Lighting", Float) = 0.0
        //[NoScaleOffset]
        // Only needed for IBL – so we can skip it
        //_PreIntegratedLUT           ("    Preintegrated LUT", 2D) = "white" {}
        _SheenColor                 ("    Sheen Color", Color) = (0.5, 0.5, 0.5)

        [Header(GGX anisotropic Lighting)]
        [Space(5)]
        _Anisotropy                 ("    Anisotropy", Range(-1.0, 1.0)) = 0.0

        [Header(Transmission)]
        [Space(5)]
        [Toggle(_SCATTERING)]
        _UseScattering              ("Enable Transmission", Float) = 0.0
        _TranslucencyPower          ("    Power", Range(0.0, 32.0)) = 7.0
        _TranslucencyStrength       ("    Strength", Range(0.0, 1.0)) = 1.0
        _ShadowStrength             ("    Shadow Strength", Range(0.0, 1.0)) = 0.7
        _Distortion                 ("    Distortion", Range(0.0, 0.1)) = 0.01


        [Header(Surface Inputs)]
        [Space(5)]
        [MainColor]
        _BaseColor                  ("Color", Color) = (1,1,1,1)
        [MainTexture]
        _BaseMap                    ("Albedo (RGB) Smoothness (A)", 2D) = "white" {}

        [Space(5)]
        _Smoothness                 ("Smoothness", Range(0.0, 1.0)) = 0.5
        _SpecColor                  ("Specular", Color) = (0.2, 0.2, 0.2)

        [Space(5)]
        [Toggle(_NORMALMAP)]
        _ApplyNormal                ("Enable Normal Map", Float) = 0.0
        [NoScaleOffset]
        _BumpMap                    ("    Normal Map", 2D) = "bump" {}
        _BumpScale                  ("    Normal Scale", Float) = 1.0

        [Space(5)]
        [Toggle(_MASKMAP)]
        _EnableMaskMap              ("Enable Mask Map", Float) = 0.0
        _MaskMap                    ("    Thickness (G) Occlusion (B) Alpha (A)", 2D) = "white" {}
        _OcclusionStrength          ("    Occlusion", Range(0.0, 1.0)) = 1
        

        [Header(Rim Lighting)]
        [Space(5)]
        [Toggle(_RIMLIGHTING)]
        _Rim                        ("Enable Rim Lighting", Float) = 0
        [HDR] _RimColor                   ("Rim Color", Color) = (0.5,0.5,0.5,1)
        _RimPower                   ("Rim Power", Float) = 2
        _RimFrequency               ("Rim Frequency", Float) = 0
        _RimMinPower                ("    Rim Min Power", Float) = 1
        _RimPerPositionFrequency    ("    Rim Per Position Frequency", Range(0.0, 1.0)) = 1


        [Header(Stencil)]
        [Space(5)]
        [IntRange] _Stencil         ("Stencil Reference", Range (0, 255)) = 0
        [IntRange] _ReadMask        ("    Read Mask", Range (0, 255)) = 255
        [IntRange] _WriteMask       ("    Write Mask", Range (0, 255)) = 255
        [Enum(UnityEngine.Rendering.CompareFunction)]
        _StencilComp                ("Stencil Comparison", Int) = 8     // always – terrain should be the first thing being rendered anyway
        [Enum(UnityEngine.Rendering.StencilOp)]
        _StencilOp                  ("Stencil Operation", Int) = 0      // 0 = keep, 2 = replace
        [Enum(UnityEngine.Rendering.StencilOp)]
        _StencilFail                ("Stencil Fail Op", Int) = 0           // 0 = keep
        [Enum(UnityEngine.Rendering.StencilOp)] 
        _StencilZFail               ("Stencil ZFail Op", Int) = 0          // 0 = keep


        [Header(Advanced)]
        [Space(5)]
        //[ToggleOff]
        //_SpecularHighlights       ("Enable Specular Highlights", Float) = 1.0
        [ToggleOff]
        _EnvironmentReflections     ("Environment Reflections", Float) = 1.0
        [Space(5)]
        [Toggle(_RECEIVE_SHADOWS_OFF)]
        _Shadows                    ("Disable Receive Shadows", Float) = 0.0


        [Header(Render Queue)]
        [Space(5)]
        [IntRange] _QueueOffset     ("Queue Offset", Range(-50, 50)) = 0


    //  Needed by the inspector
        [HideInInspector] _Culling  ("Culling", Float) = 0.0
        [HideInInspector] _AlphaFromMaskMap  ("AlphaFromMaskMap", Float) = 1.0

    //  Lightmapper and outline selection shader need _MainTex, _Color and _Cutoff
        [HideInInspector] _MainTex  ("Albedo", 2D) = "white" {}
        [HideInInspector] _Color    ("Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        LOD 100

        Pass
        {
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
            }
            

            ZWrite On
            Cull [_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard SRP library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

        //  Shader target needs to be 3.0 due to tex2Dlod in the vertex shader and VFACE
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #define _SPECULAR_SETUP 1

            #pragma shader_feature _ALPHATEST_ON

            #pragma shader_feature_local _COTTONWOOL
            #pragma shader_feature_local _MASKMAP
            #pragma shader_feature_local _SCATTERING

            #pragma shader_feature _NORMALMAP
            #pragma shader_feature_local _RIMLIGHTING

            //#pragma shader_feature _SPECULARHIGHLIGHTS_OFF // does not make sense here
            #pragma shader_feature _ENVIRONMENTREFLECTIONS_OFF
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

        //  Include base inputs and all other needed "base" includes
            #include "Includes/Lux URP Cloth Inputs.hlsl"

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

        //--------------------------------------
        //  Vertex shader


            VertexOutput LitPassVertex(VertexInput input)
            {
                VertexOutput output = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs vertexInput; // 
                vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                half3 viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;
                half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

                output.uv.xy = TRANSFORM_TEX(input.texcoord, _BaseMap);
                #if defined(_MASKMAP)
                    output.uv.zw = TRANSFORM_TEX(input.texcoord, _MaskMap);
                #endif  

                #if defined(_NORMALMAP) || !defined(_COTTONWOOL)
                    output.normalWS = half4(normalInput.normalWS, viewDirWS.x);
                    output.tangentWS = half4(normalInput.tangentWS, viewDirWS.y);
                    output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.z);
                #else
                    output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
                    output.viewDirWS = viewDirWS;
                #endif

                OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);
                
                output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

                #ifdef _ADDITIONAL_LIGHTS
                    output.positionWS = vertexInput.positionWS;
                #endif

                #if defined(_MAIN_LIGHT_SHADOWS) && !defined(_RECEIVE_SHADOWS_OFF)
                    output.shadowCoord = GetShadowCoord(vertexInput);
                #endif
                output.positionCS = vertexInput.positionCS;

                return output;
            }

        //--------------------------------------
        //  Fragment shader and functions

            inline void InitializeSurfaceData(
                #if defined(_MASKMAP)
                    float4 uv,
                #else
                    float2 uv,
                #endif
                out SurfaceDescription outSurfaceData)
            {
                half4 albedoSmoothness = SampleAlbedoAlpha(uv.xy, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));

                #if defined(_MASKMAP)
                    half4 maskSample = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, uv.zw);
                    outSurfaceData.translucency = maskSample.g;
                    //outSurfaceData.skinMask = SSSAOSample.r;
                    outSurfaceData.occlusion = lerp(1.0h, maskSample.b, _OcclusionStrength);
                    
                #else
                    outSurfaceData.translucency = 1;
                    outSurfaceData.occlusion = 1;
                #endif 

                #if defined(_ALPHATEST_ON) && defined(_MASKMAP)
                    outSurfaceData.alpha = Alpha(maskSample.a, 1, _Cutoff);
                #else
                    outSurfaceData.alpha = 1;
                #endif
                
                outSurfaceData.albedo = albedoSmoothness.rgb * _BaseColor.rgb;
                outSurfaceData.metallic = 0;
                outSurfaceData.specular = _SpecColor;
                outSurfaceData.smoothness = albedoSmoothness.a * _Smoothness;
            
            //  Normal Map
                #if defined (_NORMALMAP)
                    outSurfaceData.normalTS = SampleNormal(uv.xy, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
                #else
                    outSurfaceData.normalTS = half3(0,0,1);
                #endif

                outSurfaceData.emission = 0;
            }

            void InitializeInputData(VertexOutput input, half3 normalTS, half facing, out InputData inputData)
            {
                inputData = (InputData)0;
                #ifdef _ADDITIONAL_LIGHTS
                    inputData.positionWS = input.positionWS;
                #endif
                
                #if defined(_NORMALMAP) || !defined(_COTTONWOOL)
                    half3 viewDirWS = half3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
                    normalTS.z *= facing;
                    inputData.normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
                #else
                    half3 viewDirWS = input.viewDirWS;
                    inputData.normalWS = input.normalWS * facing;
                #endif

                inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
                viewDirWS = SafeNormalize(viewDirWS);

                inputData.viewDirectionWS = viewDirWS;
                #if defined(_MAIN_LIGHT_SHADOWS) && !defined(_RECEIVE_SHADOWS_OFF)
                    inputData.shadowCoord = input.shadowCoord;
                #else
                    inputData.shadowCoord = float4(0, 0, 0, 0);
                #endif
                inputData.fogCoord = input.fogFactorAndVertexLight.x;
                inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
                inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
            }

            half4 LitPassFragment(VertexOutput input, half facing : VFACE) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

            //  Get the surface description
                SurfaceDescription surfaceData;
                InitializeSurfaceData(input.uv, surfaceData);

            //  Prepare surface data (like bring normal into world space and get missing inputs like gi)
                InputData inputData;
                InitializeInputData(input, surfaceData.normalTS, facing, inputData);

                #if defined(_RIMLIGHTING)
                    half rim = saturate(1.0h - saturate( dot(inputData.normalWS, inputData.viewDirectionWS) ) );
                    half power = _RimPower;
                    UNITY_BRANCH if(_RimFrequency > 0 ) {
                        half perPosition = lerp(0.0h, 1.0h, dot(1.0h, frac(UNITY_MATRIX_M._m03_m13_m23) * 2.0h - 1.0h ) * _RimPerPositionFrequency ) * 3.1416h;
                        power = lerp(power, _RimMinPower, (1.0h + sin(_Time.y * _RimFrequency + perPosition) ) * 0.5h );
                    }
                    surfaceData.emission += pow(rim, power) * _RimColor.rgb * _RimColor.a;
                #endif

            //  Apply lighting
                half4 color = LuxLWRPClothFragmentPBR(
                        inputData, 
                        surfaceData.albedo,
                        surfaceData.metallic, 
                        surfaceData.specular, 
                        surfaceData.smoothness, 
                        surfaceData.occlusion, 
                        surfaceData.emission, 
                        surfaceData.alpha,
                        #if !defined(_COTTONWOOL)
                            input.tangentWS.xyz,
                            input.bitangentWS.xyz,
                        #else
                            half3(0,0,0),
                            half3(0,0,0),
                        #endif
                        _Anisotropy,
                        _SheenColor,

                        #if defined(_SCATTERING)
                            half4(surfaceData.translucency * _TranslucencyStrength, _TranslucencyPower, _ShadowStrength, _Distortion)
                        #else
                            half4(0,0,0,0)
                        #endif

                );    
            //  Add fog
                color.rgb = MixFog(color.rgb, inputData.fogCoord);
                return color;
            }

            ENDHLSL
        }


    //  Shadows -----------------------------------------------------
        
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            Cull Off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature_local _MASKMAP


            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

        //  Include base inputs and all other needed "base" includes
            #include "Includes/Lux URP Cloth Inputs.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            
        //  Shadow caster specific input
            float3 _LightDirection;

            VertexOutput ShadowPassVertex(VertexInput input)
            {
                VertexOutput output = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                #if defined(_ALPHATEST_ON) && defined(_MASKMAP)
                    output.uv.xy = TRANSFORM_TEX(input.texcoord, _MaskMap);
                #endif

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldDir(input.normalOS);

                output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS * _ShadowOffset, _LightDirection));
                #if UNITY_REVERSED_Z
                    output.positionCS.z = min(output.positionCS.z, output.positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #else
                    output.positionCS.z = max(output.positionCS.z, output.positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #endif
                return output;
            }

            half4 ShadowPassFragment(VertexOutput input) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                #if defined(_ALPHATEST_ON) && defined(_MASKMAP)
                    half mask = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, input.uv).a;
                    clip (mask - _Cutoff);
                #endif


                return 0;
            }
            ENDHLSL
        }

    //  Depth -----------------------------------------------------

        Pass
        {
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull Off

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
            #pragma shader_feature_local _MASKMAP

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #define DEPTHONLYPASS
            #include "Includes/Lux URP Cloth Inputs.hlsl"

            VertexOutput DepthOnlyVertex(VertexInput input)
            {
                VertexOutput output = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                #if defined(_ALPHATEST_ON) && defined(_MASKMAP)
                    output.uv.xy = TRANSFORM_TEX(input.texcoord, _MaskMap);
                #endif

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return output;
            }

            half4 DepthOnlyFragment(VertexOutput input) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                #if defined(_ALPHATEST_ON) && defined(_MASKMAP)
                    half mask = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, input.uv.xy).a;
                    clip (mask - _Cutoff);
                #endif

                return 0;
            }

            ENDHLSL
        }

    //  Meta -----------------------------------------------------
        
        Pass
        {
            Tags{"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles

            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMeta

            #define _SPECULAR_SETUP

        //  First include all our custom stuff
            #include "Includes/Lux URP Cloth Inputs.hlsl"

        //--------------------------------------
        //  Fragment shader and functions

            inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
            {
                half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
                outSurfaceData.alpha = 1;
                outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
                outSurfaceData.metallic = 0;
                outSurfaceData.specular = _SpecColor;
                outSurfaceData.smoothness = _Smoothness;
                outSurfaceData.normalTS = half3(0,0,1);
                outSurfaceData.occlusion = 1;
                outSurfaceData.emission = 0;
            }

        //  Finally include the meta pass related stuff  
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitMetaPass.hlsl"

            ENDHLSL
        }

    //  End Passes -----------------------------------------------------
    
    }
    FallBack "Hidden/InternalErrorShader"
    CustomEditor "LuxURPUniversalCustomShaderGUI"
}
