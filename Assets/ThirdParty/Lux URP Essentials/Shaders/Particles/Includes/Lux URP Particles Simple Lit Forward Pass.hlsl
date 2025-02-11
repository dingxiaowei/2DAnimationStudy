#ifndef LUXLWRP_SIMPLE_LIT_PASS_INCLUDED
#define LUXLWRP_SIMPLE_LIT_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Particles.hlsl"




struct AttributesParticle
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    half4 color : COLOR;
    #if defined(_FLIPBOOKBLENDING_ON) && !defined(UNITY_PARTICLE_INSTANCING_ENABLED)
        float4 texcoords : TEXCOORD0;
        #if defined (_PERVERTEX_SAMPLEOFFSET)
            float4 texcoordBlend : TEXCOORD1;
        #else
            float texcoordBlend : TEXCOORD1;
        #endif
    #else
        #if defined (_PERVERTEX_SAMPLEOFFSET)
            float4 texcoords : TEXCOORD0;
            float texcoordBlend : TEXCOORD1;
        #else
            float2 texcoords : TEXCOORD0;
        #endif
    #endif
    #if defined(_NORMALMAP)
        float4 tangent : TANGENT;
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct VaryingsParticle
{
    half4 color                     : COLOR;
    float2 texcoord                 : TEXCOORD0;
    float4 positionWS               : TEXCOORD1;

    #ifdef _NORMALMAP
        half4 normalWS              : TEXCOORD2;    // xyz: normal, w: viewDir.x
        half4 tangentWS             : TEXCOORD3;    // xyz: tangent, w: viewDir.y
        half4 bitangentWS           : TEXCOORD4;    // xyz: bitangent, w: viewDir.z
    #else
        half3 normalWS              : TEXCOORD2;
        half3 viewDirWS             : TEXCOORD3;
    #endif

    #if defined(_FLIPBOOKBLENDING_ON)
        float3 texcoord2AndBlend    : TEXCOORD5;
    #endif
    #if defined(_SOFTPARTICLES_ON) || defined(_FADING_ON) || defined(_DISTORTION_ON)
        float4 projectedPosition    : TEXCOORD6;
    #endif

//  Passing shadowCoord from vertex to fragment produced too many artifacts
    //#if (defined(_MAIN_LIGHT_SHADOWS) && !defined(_RECEIVE_SHADOWS_OFF)) || defined(_PERVERTEX_SHADOWS)
    //  float4 shadowCoord          : TEXCOORD7;
    //#endif
//  So we split the work between vertex and fragment and only calculate the cascade in the vertex shader
//  Ok on metal but still not perfect on dx11
//  uint cascade                    : TEXCOORD7;

    float3 vertexSH                 : TEXCOORD7; // SH Lighting
    half4 lighting                  : TEXCOORD8; // Per vertex sampled shadows

    #if defined _ADDITIONAL_LIGHTS_VERTEX
        half3 vertexLighting        : TEXCOORD9;
    #endif

    float4 clipPos                  : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};


void InitializeInputData(VaryingsParticle input, half3 normalTS, out InputData output) {
    output = (InputData)0;
    output.positionWS = input.positionWS.xyz;
    #ifdef _NORMALMAP
        half3 viewDirWS = half3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
        output.normalWS = TransformTangentToWorld(normalTS,
            half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
    #else
        half3 viewDirWS = input.viewDirWS;
        output.normalWS = input.normalWS;
    #endif
    output.normalWS = NormalizeNormalPerPixel(output.normalWS);
    #if SHADER_HINT_NICE_QUALITY
        viewDirWS = SafeNormalize(viewDirWS);
    #endif
    output.viewDirectionWS = viewDirWS;
    //#if (defined(_MAIN_LIGHT_SHADOWS) && !defined(_RECEIVE_SHADOWS_OFF)) || defined(_PERVERTEX_SHADOWS)
    //output.shadowCoord = input.shadowCoord;
    // #else
    output.shadowCoord = float4(1, 1, 1, 1);
    // #endif
    output.fogCoord = (half)input.positionWS.w;

    #if defined _ADDITIONAL_LIGHTS_VERTEX
        output.vertexLighting = input.vertexLighting;
    #else
        output.vertexLighting = half3(0.0h, 0.0h, 0.0h);
    #endif
    output.bakedGI = SampleSHPixel(input.vertexSH, output.normalWS);
}

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

VaryingsParticle ParticlesLitVertex(AttributesParticle input)
{
    VaryingsParticle output;
    
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.vertex.xyz);
//  In order to get rid of the tangent we have to add and #if here.
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal,
        #if defined(_NORMALMAP)
            input.tangent
        #else
            float4 (0,0,0,0)
        #endif
    );
    half3 viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;
    #if !SHADER_HINT_NICE_QUALITY
        viewDirWS = SafeNormalize(viewDirWS);
    #endif

    #ifdef _NORMALMAP
        output.normalWS = half4(normalInput.normalWS, viewDirWS.x);
        output.tangentWS = half4(normalInput.tangentWS, viewDirWS.y);
        output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.z);
    #else
        output.normalWS = normalInput.normalWS;
        output.viewDirWS = viewDirWS;
    #endif

    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    output.positionWS.xyz = vertexInput.positionWS.xyz;
//  NOTE: output.positionWS.w contains fog!
    output.positionWS.w = ComputeFogFactor(vertexInput.positionCS.z);
    
    output.clipPos = vertexInput.positionCS;
    output.color = input.color;
    
    output.texcoord = input.texcoords.xy;
    #ifdef _FLIPBOOKBLENDING_ON
        output.texcoord2AndBlend.xy = input.texcoords.zw;
        output.texcoord2AndBlend.z = input.texcoordBlend.x;
    #endif

    #if defined(_SOFTPARTICLES_ON) || defined(_FADING_ON) || defined(_DISTORTION_ON)
        output.projectedPosition = ComputeScreenPos(vertexInput.positionCS);
    #endif

    #if defined _ADDITIONAL_LIGHTS_VERTEX
        output.vertexLighting = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
    #endif

//    #if (defined(_MAIN_LIGHT_SHADOWS) && !defined(_RECEIVE_SHADOWS_OFF)) || defined(_PERVERTEX_SHADOWS)
//      We do not need the screen space shadow coords
//      output.shadowCoord = GetShadowCoord(vertexInput);
//        output.shadowCoord = TransformWorldToShadowCoord(output.positionWS.xyz);
//    #endif

//  output.cascade = (uint)floor(ComputeCascadeIndex(output.positionWS.xyz));
    output.lighting = half4(1,1,1,1);

    #if defined(_PERVERTEX_SHADOWS)
    //  Main Light shadows - we do not sample the screen space shadowmap but the cascaded map
        #ifdef _MAIN_LIGHT_SHADOWS_CASCADE
            half cascade = ComputeCascadeIndex(output.positionWS.xyz);
            float4 shadowCoord = mul(_MainLightWorldToShadow[cascade], float4(output.positionWS.xyz, 1.0));
        #else
            float4 shadowCoord = mul(_MainLightWorldToShadow[0], float4(output.positionWS.xyz, 1.0));
        #endif

        ShadowSamplingData shadowSamplingData = GetMainLightShadowSamplingData();
        half shadowStrength = GetMainLightShadowStrength();
        output.lighting.a = SampleShadowmap(shadowCoord, TEXTURE2D_ARGS(_MainLightShadowmapTexture, sampler_MainLightShadowmapTexture), shadowSamplingData, shadowStrength, false);

    //  Multi sample and blend directional shadows. Offset is derived from velocity.
        #if defined(_PERVERTEX_SAMPLEOFFSET)
            #ifdef _FLIPBOOKBLENDING_ON
                float3 vel = normalize(input.texcoordBlend.yzw) * _SampleOffset;
            #else
                float3 vel = normalize( float3(input.texcoords.zw, input.texcoordBlend.x)) * _SampleOffset;
            #endif
            float4 sc = TransformWorldToShadowCoord(output.positionWS.xyz + vel);
            output.lighting.a += SampleShadowmap(sc, TEXTURE2D_ARGS(_MainLightShadowmapTexture, sampler_MainLightShadowmapTexture), shadowSamplingData, shadowStrength, false);
            sc = TransformWorldToShadowCoord(output.positionWS.xyz - vel);
            output.lighting.a += SampleShadowmap(sc, TEXTURE2D_ARGS(_MainLightShadowmapTexture, sampler_MainLightShadowmapTexture), shadowSamplingData, shadowStrength, false);
            output.lighting.a /= 3;
        #endif

        #if defined (_ADDITIONALLIGHT_SHADOWS)
            int pixelLightCount = GetAdditionalLightsCount();
        //  Limit pixelLightCount to 3 as we only have 4 entries ( last one used by the directional light)
            pixelLightCount = min(3, pixelLightCount);
            float shadow[3] = {(1), (1), (1)};
            for (int i = 0; i < pixelLightCount; i++) {
                int PerObjectLightIndex = GetPerObjectLightIndex(i);
            //  DX11 does not like this
                //output.lighting[i] = AdditionalLightRealtimeShadow(PerObjectLightIndex, output.positionWS.xyz);
                shadow[i] = AdditionalLightRealtimeShadow(PerObjectLightIndex, output.positionWS.xyz);
            }
            output.lighting.xyz = half3(shadow[0], shadow[1], shadow[2]);
        #endif
    #endif
    return output;
}

// Lighting

half3 LuxLightingLambertTransmission(half3 lightColor, half3 lightDir, half3 normal, half3 viewDir, half strength)
{
    half NdotL = saturate(dot(normal, lightDir));
    #if defined(_TRANSMISSION)
        return lightColor * saturate(NdotL) + lightColor * saturate(dot(-viewDir, lightDir + normal * _TransmissionDistortion)) * strength;
    #else
        return lightColor * NdotL;
    #endif
}

half4 LuxBlinnPhong(InputData inputData, half3 diffuse, half4 specularGloss, half smoothness, half3 emission, half alpha, float4 inputLighting, half transmission, uint cascade)
{
    Light mainLight = GetMainLight(inputData.shadowCoord);
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, half4(0, 0, 0, 0));

    //transmission *= 1.0h - alpha;

    #if defined(_PERVERTEX_SHADOWS)
    //  Here shadowAttenuation never gets used so it should be stripped by the compiler...
        half3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation);
        attenuatedLightColor *= inputLighting.a;
    #else
        half3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation); // * mainLight.shadowAttenuation);
    //  Main Light shadows - We do not sample the screen space shadowmap but the cascaded map
        ShadowSamplingData shadowSamplingData = GetMainLightShadowSamplingData();
    //  Vertex to fragment interpolation procudes too many errors?
    //  inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS.xyz); // - inputData.normalWS*0.5);

    //  Using uint cascade actually looks fine on Metal but not dx11, so we actually do all the calculation per pixel
    /*  #ifdef _MAIN_LIGHT_SHADOWS_CASCADE
            float4 shadowCoord = mul(_MainLightWorldToShadow[cascade], float4(inputData.positionWS, 1.0));
        #else
            float4 shadowCoord = mul(_MainLightWorldToShadow[0], float4(inputData.positionWS, 1.0));
        #endif
    */
        float4 shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
        half shadowStrength = GetMainLightShadowStrength();
        attenuatedLightColor *= SampleShadowmap(shadowCoord, TEXTURE2D_ARGS(_MainLightShadowmapTexture, sampler_MainLightShadowmapTexture), shadowSamplingData, shadowStrength, false);
    #endif

    half3 diffuseColor = inputData.bakedGI + LuxLightingLambertTransmission(attenuatedLightColor, mainLight.direction, inputData.normalWS, inputData.viewDirectionWS, transmission);
    half3 specularColor = LightingSpecular(attenuatedLightColor, mainLight.direction, inputData.normalWS, inputData.viewDirectionWS, specularGloss, smoothness);

    #ifdef _ADDITIONAL_LIGHTS
        int pixelLightCount = GetAdditionalLightsCount();
        #if defined(_PERVERTEX_SHADOWS) && defined(_ADDITIONALLIGHT_SHADOWS)
        //  Metal does not like to access the components using indices?! So we chose another way.
            float shadow[4] = {(inputLighting.x), (inputLighting.y), (inputLighting.z), (inputLighting.w)};
        #endif
        for (int i = 0; i < pixelLightCount; i++) {
            Light light = GetAdditionalLight(i, inputData.positionWS);
            #if defined(_PERVERTEX_SHADOWS)
            //  Here shadowAttenuation never gets used so it should be stripped by the compiler...
                half3 attenuatedLightColor = light.color * (light.distanceAttenuation);
                #if defined(_ADDITIONALLIGHT_SHADOWS)
                //  make sure we use the same LightIndex and do not sample more than we have.
                    attenuatedLightColor *= (i < 3) ? shadow[i] : 1.0h;
                #endif
            #else
                half3 attenuatedLightColor = light.color * (light.distanceAttenuation
                #if defined(_ADDITIONALLIGHT_SHADOWS)
                    * light.shadowAttenuation
                #endif
                );
            #endif
            diffuseColor += LuxLightingLambertTransmission(attenuatedLightColor, light.direction, inputData.normalWS, inputData.viewDirectionWS, transmission);
            specularColor += LightingSpecular(attenuatedLightColor, light.direction, inputData.normalWS, inputData.viewDirectionWS, specularGloss, smoothness);
        }
    #endif

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        diffuseColor += inputData.vertexLighting;
    #endif

    half3 finalColor = diffuseColor * diffuse + emission;

    #if defined(_SPECGLOSSMAP) || defined(_SPECULAR_COLOR)
        #if !defined(_SPECULARHIGHLIGHTS_OFF)
            finalColor += specularColor;
        #endif
    #endif

    return half4(finalColor, alpha);
}


half4 ParticlesLitFragment(VaryingsParticle input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 uv = input.texcoord;
    float3 blendUv = float3(0, 0, 0);
    #if defined(_FLIPBOOKBLENDING_ON)
        blendUv = input.texcoord2AndBlend;
    #endif

    float4 projectedPosition = float4(0,0,0,0);
    #if defined(_SOFTPARTICLES_ON) || defined(_FADING_ON) || defined(_DISTORTION_ON)
        projectedPosition = input.projectedPosition;
    #endif


//  Fix screenUV for Single Pass Stereo Rendering
#if defined(UNITY_SINGLE_PASS_STEREO)
    projectedPosition.xy /= projectedPosition.w;
    projectedPosition.w = 1.0f; // Reset
    //projectedPosition.x = projectedPosition.x * 0.5f + (float)unity_StereoEyeIndex * 0.5f;
    projectedPosition.xy = UnityStereoTransformScreenSpaceTex(projectedPosition.xy);
#endif

    
    half4 albedo = Lux_SampleAlbedo(uv, blendUv, _BaseColor, input.color, projectedPosition, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
//  Early out
    clip(albedo.a - 0.001h);
    
    half3 normalTS = SampleNormalTS(uv, blendUv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));

//  We do not use the macro here
    half3 diffuse = albedo.rgb; //AlphaModulate(albedo.rgb, albedo.a);


    half alpha = albedo.a;
    #if defined(_EMISSION)
        half3 emission = BlendTexture(TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap), uv, blendUv).rgb * _EmissionColor.rgb;
    #else
        half3 emission = half3(0, 0, 0);
    #endif

    //_SpecColor.a *= _Smoothness;

    half4 specularGloss = SampleSpecularSmoothness(uv, blendUv, albedo.a, _SpecColor, TEXTURE2D_ARGS(_SpecGlossMap, sampler_SpecGlossMap));
    half shininess = specularGloss.a;
    
    #if defined(_DISTORTION_ON)
        diffuse = Distortion(half4(diffuse, alpha), normalTS, _DistortionStrengthScaled, _DistortionBlend, projectedPosition);
    #endif

    InputData inputData;
    InitializeInputData(input, normalTS, inputData);

    half4 color = LuxBlinnPhong(inputData, diffuse, specularGloss, shininess, emission, alpha, input.lighting, _Transmission, 0 /*input.cascade*/);


    #if defined(_ADDITIVE)
    //  Add fog
        color.rgb = MixFogColor(color.rgb, half3(0,0,0), inputData.fogCoord);
    #else
    //  Add fog
        color.rgb = MixFog(color.rgb, inputData.fogCoord);
    #endif

    #if defined(_ALPHAPREMULTIPLY_ON)
        color.rgb = color.rgb * color.a;
    #endif

    return color;
}


///////////////////////////////////////////////////////////////////////////////
//                       Tesellation functions                               //
///////////////////////////////////////////////////////////////////////////////

#if defined(_USESTESSELLATION)

    real3 GetDistanceBasedTessFactor(real3 p0, real3 p1, real3 p2, real3 cameraPosWS, real tessMinDist, real tessMaxDist)
    {
        real3 edgePosition0 = 0.5 * (p1 + p2);
        real3 edgePosition1 = 0.5 * (p0 + p2);
        real3 edgePosition2 = 0.5 * (p0 + p1);

        // In case camera-relative rendering is enabled, 'cameraPosWS' is statically known to be 0,
        // so the compiler will be able to optimize distance() to length().
        real dist0 = distance(edgePosition0, cameraPosWS);
        real dist1 = distance(edgePosition1, cameraPosWS);
        real dist2 = distance(edgePosition2, cameraPosWS);

        // The saturate will handle the produced NaN in case min == max
        real fadeDist = tessMaxDist - tessMinDist;
        real3 tessFactor;
        tessFactor.x = saturate(1.0 - (dist0 - tessMinDist) / fadeDist);
        tessFactor.y = saturate(1.0 - (dist1 - tessMinDist) / fadeDist);
        tessFactor.z = saturate(1.0 - (dist2 - tessMinDist) / fadeDist);

        return tessFactor;
    }


    // More or less the same as AttributesParticle
    struct TessVertex {
        float4 vertex : INTERNALTESSPOS;
        float3 normal : NORMAL;
        half4 color : COLOR;
        #if defined(_FLIPBOOKBLENDING_ON) && !defined(UNITY_PARTICLE_INSTANCING_ENABLED)
            float4 texcoords : TEXCOORD0;
            #if defined (_PERVERTEX_SAMPLEOFFSET)
                float4 texcoordBlend : TEXCOORD1;
            #else
               float texcoordBlend : TEXCOORD1;
            #endif
        #else
            #if defined (_PERVERTEX_SAMPLEOFFSET)
                float4 texcoords : TEXCOORD0;
            #else
                float2 texcoords : TEXCOORD0;
            #endif
        #endif
        #if defined(_NORMALMAP)
            float4 tangent : TANGENT;
        #endif
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };


    struct OutputPatchConstant {
        float edge[3]         : SV_TessFactor;
        float inside          : SV_InsideTessFactor;
    };


    //  The Vertex Shader - simply copies the inputs
    TessVertex ParticlesLitTessVertex (AttributesParticle input) {
        TessVertex o;
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_TRANSFER_INSTANCE_ID(input, o); // Fine, now the vertex shader outputs the id
        o.vertex    = input.vertex;
        o.normal    = input.normal;
        o.color     = input.color;
        #if defined(_FLIPBOOKBLENDING_ON) && !defined(UNITY_PARTICLE_INSTANCING_ENABLED)
            o.texcoords = input.texcoords;
            o.texcoordBlend = input.texcoordBlend;
        #else
            o.texcoords = input.texcoords;
        #endif
        #if defined(_NORMALMAP)
            o.tangent = input.tangent;
        #endif
        return o;
    }

    float4 Tessellation(TessVertex v, TessVertex v1, TessVertex v2) {
        real4 tess;
        tess.xyz = _Tess * clamp(GetDistanceBasedTessFactor (v.vertex.xyz, v1.vertex.xyz, v2.vertex.xyz, _WorldSpaceCameraPos, _TessRange.x, _TessRange.y ), 0.01, 1 );
        tess.w = (tess.x + tess.y + tess.z) / 3.0;
        return tess;
    }

    OutputPatchConstant hullconst (InputPatch<TessVertex,3> v) {
        OutputPatchConstant o;
        float4 ts = Tessellation( v[0], v[1], v[2]);
        o.edge[0] = ts.x;
        o.edge[1] = ts.y;
        o.edge[2] = ts.z;
        o.inside = ts.w;
        return o;
    }

    [domain("tri")]
    [partitioning("fractional_odd")]
    [outputtopology("triangle_cw")]
    [patchconstantfunc("hullconst")]
    [outputcontrolpoints(3)]
    TessVertex ParticlesLitHull (InputPatch<TessVertex,3> v, uint id : SV_OutputControlPointID) {
        return v[id];
    }

    [domain("tri")]
    VaryingsParticle ParticlesLitDomain (OutputPatchConstant tessFactors, const OutputPatch<TessVertex,3> vi, float3 bary : SV_DomainLocation) {
        AttributesParticle v = (AttributesParticle)0;
        v.vertex = vi[0].vertex*bary.x + vi[1].vertex*bary.y + vi[2].vertex*bary.z;
        v.normal = vi[0].normal*bary.x + vi[1].normal*bary.y + vi[2].normal*bary.z;
        v.color = vi[0].color*bary.x + vi[1].color*bary.y + vi[2].color*bary.z;
        #if defined(_FLIPBOOKBLENDING_ON) && !defined(UNITY_PARTICLE_INSTANCING_ENABLED)
            v.texcoords = vi[0].texcoords*bary.x + vi[1].texcoords*bary.y + vi[2].texcoords*bary.z;
            v.texcoordBlend = vi[0].texcoordBlend*bary.x + vi[1].texcoordBlend*bary.y + vi[2].texcoordBlend*bary.z;
        #else
            v.texcoords = vi[0].texcoords*bary.x + vi[1].texcoords*bary.y + vi[2].texcoords*bary.z;
        #endif
        #if defined(_NORMALMAP)
            v.tangent = vi[0].tangent*bary.x + vi[1].tangent*bary.y + vi[2].tangent*bary.z;
        #endif
    //  UNITY_SETUP_INSTANCE_ID(vi[0]);
    //  This is all we need?
        UNITY_TRANSFER_INSTANCE_ID(vi[0], v);
    //  Now call the regular vertex function
        VaryingsParticle o = ParticlesLitVertex(v);
        return o;
    }

#endif

// ---------------------------

#endif // LUXLWRP_SIMPLE_LIT_PASS_INCLUDED
