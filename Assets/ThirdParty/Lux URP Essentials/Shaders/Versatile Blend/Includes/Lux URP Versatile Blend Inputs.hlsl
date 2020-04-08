#ifndef INPUT_LUXLURP_BASE_INCLUDED
#define INPUT_LUXLURP_BASE_INCLUDED



    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//  defines a bunch of helper functions (like lerpwhiteto)
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"  
//  defines SurfaceData, textures and the functions Alpha, SampleAlbedoAlpha, SampleNormal, SampleEmission
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
//  defines e.g. "DECLARE_LIGHTMAP_OR_SH"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
 
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"

//  Material Inputs
    CBUFFER_START(UnityPerMaterial)

        float _Shift;
        half _BlendWidth;
        half _BlendSharpness;

half _AlphaShift;
half _AlphaWidth;

    


    half _BumpScale;


    

        half4   _BaseColor;
        half    _Cutoff;
        float4  _BaseMap_ST;
        half    _Smoothness;
        half3   _SpecColor;

        half    _OcclusionStrength;




    CBUFFER_END

//  Additional textures
    #if defined(_MASKMAP)
        TEXTURE2D(_MaskMap); SAMPLER(sampler_MaskMap);
    #endif
//  Depth texture
    #if defined(SHADER_API_GLES)
        TEXTURE2D(_CameraDepthTexture); SAMPLER(sampler_CameraDepthTexture);
    #else
        TEXTURE2D_X_FLOAT(_CameraDepthTexture);
        float4 _CameraDepthTexture_TexelSize;
    #endif
    

//  Global Inputs

//  Structs
    struct VertexInput
    {
        float3 positionOS                   : POSITION;
        float3 normalOS                     : NORMAL;
        float4 tangentOS                    : TANGENT;
        float2 texcoord                     : TEXCOORD0;
        float2 lightmapUV                   : TEXCOORD1;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };
    
    struct VertexOutput
    {
        float4 positionCS                   : SV_POSITION;
        float2 uv                           : TEXCOORD0;

        #if !defined(UNITY_PASS_SHADOWCASTER) && !defined(DEPTHONLYPASS)
            DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
            //#ifdef _ADDITIONAL_LIGHTS
                float3 positionWS           : TEXCOORD2;
            //#endif
            #if defined(_NORMALMAP)
                half4 normalWS              : TEXCOORD3;
                half4 tangentWS             : TEXCOORD4;
                half4 bitangentWS           : TEXCOORD5;
            #else
                half3 normalWS              : TEXCOORD3;
                half3 viewDirWS             : TEXCOORD4;
            #endif

            half4 fogFactorAndVertexLight   : TEXCOORD6;
        //  We have to calculate shadowCoord per pixel
            //#ifdef _MAIN_LIGHT_SHADOWS
            //    float4 shadowCoord        : TEXCOORD7;
            //#endif

            float2 screenUV : TEXCOORD8;


        #endif


        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    struct SurfaceDescription
    {
        half3 albedo;
        half alpha;
        half3 normalTS;
        half3 emission;
        half metallic;
        half3 specular;
        half smoothness;
        half occlusion;
    };

#endif