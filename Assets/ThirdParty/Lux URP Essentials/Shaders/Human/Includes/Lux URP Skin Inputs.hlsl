#ifndef INPUT_LUXLWRP_BASE_INCLUDED
#define INPUT_LUXLWRP_BASE_INCLUDED

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//  defines a bunch of helper functions (like lerpwhiteto)
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"  
//  defines SurfaceData, textures and the functions Alpha, SampleAlbedoAlpha, SampleNormal, SampleEmission
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
//  defines e.g. "DECLARE_LIGHTMAP_OR_SH"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
 
    #include "../Includes/Lux URP Skin Lighting.hlsl"

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"

//  Material Inputs
    CBUFFER_START(UnityPerMaterial)

        float4 _BaseMap_ST;
        half _Smoothness;
        half3 _SpecColor;
        
        half _BumpScale;
        half _Bias;

        half _OcclusionStrength;

        half3 _SubsurfaceColor;
        half _Curvature;        
        float2 _DistanceFade;

        half _TranslucencyPower;
        half _TranslucencyStrength;
        half _ShadowStrength;
        half _Distortion;

        #if defined(_RIMLIGHTING)
            half4 _RimColor;
            half _RimPower;
            half _RimMinPower;
            half _RimFrequency;
            half _RimPerPositionFrequency;
        #endif
    CBUFFER_END

//  Additional textures
    TEXTURE2D(_SSSAOMap); SAMPLER(sampler_SSSAOMap);

//  Global Inputs

//  Structs
    struct VertexInput
    {
        float3 positionOS                   : POSITION;
        float3 normalOS                     : NORMAL;
        float4 tangentOS                    : TANGENT;
        float2 texcoord                     : TEXCOORD0;
        float2 lightmapUV                   : TEXCOORD1;
        half4 color                         : COLOR;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };
    
    struct VertexOutput
    {
        float4 positionCS                   : SV_POSITION;
        float2 uv                           : TEXCOORD0;

        half fade                           : TEXCOORD9;

        #if !defined(UNITY_PASS_SHADOWCASTER) && !defined(DEPTHONLYPASS)
            DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
            //#ifdef _ADDITIONAL_LIGHTS
                float3 positionWS           : TEXCOORD2;
            //#endif
            #ifdef _NORMALMAP
                half4 normalWS              : TEXCOORD3;
                half4 tangentWS             : TEXCOORD4;
                half4 bitangentWS           : TEXCOORD5;
            #else
                half3 normalWS              : TEXCOORD3;
                half3 viewDirWS             : TEXCOORD4;
            #endif
            half4 fogFactorAndVertexLight   : TEXCOORD6;
            #ifdef _MAIN_LIGHT_SHADOWS
                float4 shadowCoord          : TEXCOORD7;
            #endif
        #endif

        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    struct SurfaceDescription
    {
        half3 albedo;
        half alpha;
        half3 normalTS;
        half3 diffuseNormalTS;
        half3 emission;
        half metallic;
        half3 specular;
        half smoothness;
        half occlusion;
        half translucency;
        half skinMask;
    };

#endif