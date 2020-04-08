﻿// Shader uses custom editor to set double sided GI
// Needs _Culling to be set properly

Shader "Lux URP/Human/Skin"
{
    Properties
    {
        [HeaderHelpLuxURP_URL(snoamqpqhtdl)]
        
        [Header(Surface Options)]
        [Space(5)]
        [ToggleOff(_RECEIVE_SHADOWS_OFF)]
        _ReceiveShadows             ("Receive Shadows", Float) = 1.0
        
        [Header(Surface Inputs)]
        [Space(5)]
        [NoScaleOffset] [MainTexture]
        _BaseMap                    ("Albedo (RGB) Smoothness (A)", 2D) = "white" {}
        [HideInInspector] [MainColor]
        _BaseColor                  ("Color", Color) = (1,1,1,1)
        
        [Space(5)]
        _Smoothness                 ("Smoothness", Range(0.0, 1.0)) = 0.5
        _SpecColor                  ("Specular", Color) = (0.2, 0.2, 0.2)

        [Space(5)]
        [Toggle(_NORMALMAP)]
        _ApplyNormal                ("Enable Normal Map", Float) = 0.0
        [NoScaleOffset]
        _BumpMap                    ("    Normal Map", 2D) = "bump" {}
        _BumpScale                  ("    Normal Scale", Float) = 1.0
        [Toggle(_NORMALMAPDIFFUSE)]
        _ApplyNormalDiffuse         ("    Enable Diffuse Normal Sample", Float) = 0.0
        _Bias                       ("    Bias", Range(0.0, 8.0)) = 3.0

        [Header(Skin Lighting)]
        [Space(5)]
        [NoScaleOffset] _SSSAOMap   ("Skin Mask (R) Thickness (G) Occlusion (A)", 2D) = "white" {}
        
        _OcclusionStrength          ("Occlusion Strength", Range(0.0, 1.0)) = 1.0

        _Curvature                  ("Curvature", Range(0.0, 1.0)) = 0.5

        _SubsurfaceColor            ("Subsurface Color", Color) = (1.0, 0.4, 0.25, 1.0)
        _TranslucencyPower          ("Transmission Power", Range(0.0, 10.0)) = 7.0
        _TranslucencyStrength       ("Transmission Strength", Range(0.0, 1.0)) = 1.0
        _ShadowStrength             ("Shadow Strength", Range(0.0, 1.0)) = 0.7
        _Distortion                 ("Transmission Distortion", Range(0.0, 0.1)) = 0.01

        [Space(5)]
        [NoScaleOffset] _SkinLUT    ("Skin LUT", 2D) = "white" {}

        [Header(Distance Fading)]
        [Space(5)]
        [Toggle(_DISTANCEFADE)]
        _EnableDistanceFade         ("Enable Distance Fade", Float) = 0.0
        [LuxLWRPDistanceFadeDrawer]
        _DistanceFade               ("Distance Fade Params", Vector) = (2500, 0.001, 0, 0)


        [Header(Rim Lighting)]
        [Space(5)]
        [Toggle(_RIMLIGHTING)]
        _Rim                        ("Enable Rim Lighting", Float) = 0
        [HDR] _RimColor             ("Rim Color", Color) = (0.5,0.5,0.5,1)
        _RimPower                   ("Rim Power", Float) = 2
        _RimFrequency               ("Rim Frequency", Float) = 0
        _RimMinPower                ("    Rim Min Power", Float) = 1
        _RimPerPositionFrequency    ("    Rim Per Position Frequency", Range(0.0, 1.0)) = 1

        [Header(Advanced)]
        [Space(5)]
        [ToggleOff]
        _SpecularHighlights         ("Enable Specular Highlights", Float) = 1.0
        [ToggleOff]
        _EnvironmentReflections     ("Environment Reflections", Float) = 1.0


        [Header(Stencil)]
        [Space(5)]
        [IntRange] _Stencil         ("Stencil Reference", Range (0, 255)) = 0
        [IntRange] _ReadMask        ("    Read Mask", Range (0, 255)) = 255
        [IntRange] _WriteMask       ("    Write Mask", Range (0, 255)) = 255
        [Enum(UnityEngine.Rendering.CompareFunction)]
        _StencilComp                ("Stencil Comparison", Int) = 8     // always 
        [Enum(UnityEngine.Rendering.StencilOp)]
        _StencilOp                  ("Stencil Operation", Int) = 0      // 0 = keep, 2 = replace
        [Enum(UnityEngine.Rendering.StencilOp)]
        _StencilFail                ("Stencil Fail Op", Int) = 0        // 0 = keep
        [Enum(UnityEngine.Rendering.StencilOp)] 
        _StencilZFail               ("Stencil ZFail Op", Int) = 0       // 0 = keep

    //  Needed by the inspector
        [HideInInspector] _Culling  ("Culling", Float) = 0.0

    //  Lightmapper and outline selection shader need _MainTex, _Color and _Cutoff
        [HideInInspector] _MainTex  ("Albedo", 2D) = "white" {}
        [HideInInspector] _Color    ("Color", Color) = (1,1,1,1)
        [HideInInspector] _Cutoff   ("Alpha Cutoff", Range(0.0, 1.0)) = 0.0
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
            Cull Back

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard SRP library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

        //  Shader target needs to be 3.0 due to tex2Dlod in the vertex shader and VFACE
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #define _SPECULAR_SETUP 1
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature_local _NORMALMAPDIFFUSE
            #pragma shader_feature_local _DISTANCEFADE
            #pragma shader_feature_local _RIMLIGHTING

            #pragma shader_feature _SPECULARHIGHLIGHTS_OFF
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
            #include "Includes/Lux URP Skin Inputs.hlsl"

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

            //  Set distance fade value
                #if defined(_DISTANCEFADE)
                    float3 worldInstancePos = UNITY_MATRIX_M._m03_m13_m23;
                    float3 diff = (_WorldSpaceCameraPos - worldInstancePos);
                    float dist = dot(diff, diff);
                    output.fade = saturate( (_DistanceFade.x - dist) * _DistanceFade.y );
                #else
                    output.fade = 1.0h;
                #endif

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                half3 viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;
                half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

                output.uv.xy = input.texcoord;

                #ifdef _NORMALMAP
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

            inline void InitializeSkinLitSurfaceData(float2 uv, half fade, out SurfaceDescription outSurfaceData)
            {
                half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));

                outSurfaceData.alpha = 1;
                
                outSurfaceData.albedo = albedoAlpha.rgb;
                outSurfaceData.metallic = 0;
                outSurfaceData.specular = _SpecColor;
            
            //  Normal Map
                #if defined (_NORMALMAP)
                    outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
                    #if defined(_NORMALMAPDIFFUSE)
                        half4 sampleNormalDiffuse = SAMPLE_TEXTURE2D_BIAS(_BumpMap, sampler_BumpMap, uv, _Bias);
                    //  Do not manually unpack the normal map as it might use RGB.
                        outSurfaceData.diffuseNormalTS = UnpackNormal(sampleNormalDiffuse);
                    #else
                        outSurfaceData.diffuseNormalTS = half3(0,0,1);
                    #endif
                #else
                    outSurfaceData.normalTS = half3(0,0,1);
                    outSurfaceData.diffuseNormalTS = half3(0,0,1);
                #endif

                half4 SSSAOSample = SAMPLE_TEXTURE2D(_SSSAOMap, sampler_SSSAOMap, uv);
                outSurfaceData.translucency = SSSAOSample.g;
                outSurfaceData.skinMask = SSSAOSample.r;
                outSurfaceData.occlusion = lerp(1.0h, SSSAOSample.a, _OcclusionStrength);

                outSurfaceData.smoothness = albedoAlpha.a * _Smoothness;
                outSurfaceData.emission = 0;
            }

            void InitializeInputData(VertexOutput input, half3 normalTS, out InputData inputData)
            {
                inputData = (InputData)0;
                inputData.positionWS = input.positionWS;
                #ifdef _NORMALMAP
                    half3 viewDirWS = half3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
                    inputData.normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
                #else
                    half3 viewDirWS = input.viewDirWS;
                    inputData.normalWS = input.normalWS;
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

            half4 LitPassFragment(VertexOutput input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

            //  Get the surface description
                SurfaceDescription surfaceData;
                InitializeSkinLitSurfaceData(input.uv.xy, input.fade, surfaceData);

            //  Prepare surface data (like bring normal into world space and get missing inputs like gi
                InputData inputData;
                InitializeInputData(input, surfaceData.normalTS, inputData);

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
                half4 color = LuxLWRPSkinFragmentPBR(
                    inputData, 
                    surfaceData.albedo, 
                    surfaceData.metallic, 
                    surfaceData.specular, 
                    surfaceData.smoothness, 
                    surfaceData.occlusion, 
                    surfaceData.emission, 
                    surfaceData.alpha,
                //  Subsurface Scattering
                    half4(_TranslucencyStrength * surfaceData.translucency, _TranslucencyPower, _ShadowStrength, _Distortion),
                //  AmbientReflection Strength
                    1,
                //  Diffuse Normal
                    #if defined(_NORMALMAP) && defined(_NORMALMAPDIFFUSE)
                        TransformTangentToWorld(surfaceData.diffuseNormalTS, half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz))
                    #else
                        input.normalWS
                    #endif
                    ,
                    _SubsurfaceColor,
                    lerp(surfaceData.translucency, 1, _Curvature),
                //  Lerp lighting towards standard according the distance fade
                    surfaceData.skinMask * input.fade
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


            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

        //  Include base inputs and all other needed "base" includes
            #include "Includes/Lux URP Skin Inputs.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            
        //  Shadow caster specific input
            float3 _LightDirection;

            VertexOutput ShadowPassVertex(VertexInput input)
            {
                VertexOutput output = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldDir(input.normalOS);

                output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
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

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #define DEPTHONLYPASS
            #include "Includes/Lux URP Skin Inputs.hlsl"

            VertexOutput DepthOnlyVertex(VertexInput input)
            {
                VertexOutput output = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return output;
            }

            half4 DepthOnlyFragment(VertexOutput input) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
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
            #include "Includes/Lux URP Skin Inputs.hlsl"

        //--------------------------------------
        //  Fragment shader and functions

            inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
            {
                half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
                outSurfaceData.alpha = 1;
                outSurfaceData.albedo = albedoAlpha.rgb;
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
    CustomEditor "LuxURPCustomSkinShaderGUI"
    FallBack "Hidden/InternalErrorShader"
}
