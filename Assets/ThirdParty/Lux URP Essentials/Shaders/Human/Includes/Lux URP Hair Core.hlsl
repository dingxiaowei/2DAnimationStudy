#ifndef HAIR_CORE_INCLUDED
#define HAIR_CORE_INCLUDED

        //--------------------------------------
        //  Vertex shader

            VertexOutput LitPassVertex(VertexInput input)
            {
                VertexOutput output = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                half3 viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;
                half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

                output.uv.xy = input.texcoord;

            //  Hair lighting always needs tangent and bitangent
                output.normalWS = half4(normalInput.normalWS, viewDirWS.x);
                output.tangentWS = half4(normalInput.tangentWS, viewDirWS.y);
                output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.z);

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

                output.color = input.color;

                // output.screenPos = ComputeScreenPos(output.positionCS);

                return output;
            }

        //--------------------------------------
        //  Fragment shader and functions

            float Dither32(float2 Pos, float frameIndexMod4)
            {
                uint3 k0 = uint3(13, 5, 15);
                float Ret = dot(float3(Pos.xy, frameIndexMod4 + 0.5f), k0 / 32.0f);
                return frac(Ret);
            }

            //inline void InitializeHairLitSurfaceData(float2 uv, float4 screenPos, half fade, half4 vertexColor, out SurfaceDescription outSurfaceData)
            inline void InitializeHairLitSurfaceData(float2 uv, half4 vertexColor, out SurfaceDescription outSurfaceData)
            {
                half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
                outSurfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);
                
                // a2c sharpened
                // (col.a - _Cutoff) / max(fwidth(col.a), 0.0001) + 0.5;
                /*
                float2 ditherUV = screenPos.xy / screenPos.w;
                ditherUV *= _ScreenParams.xy * _Dither_TexelSize.xy;
                half BlueNoise = SAMPLE_TEXTURE2D(_Dither, sampler_Dither, ditherUV).a;
                clip(albedoAlpha.a - clamp(BlueNoise, 0.1, _Cutoff));
                outSurfaceData.alpha = 1;
                */
                //clip( albedoAlpha.a - Dither32( screenPos.xy / screenPos.w * _ScreenParams.xy, _FrameIndexMod4  ));
                
                outSurfaceData.albedo = albedoAlpha.rgb; // * _BaseColor.rgb; // * vertexColor.rgb;
                outSurfaceData.metallic = 0;
                outSurfaceData.specular = _SpecColor;
            
            //  Normal Map
                #if defined (_NORMALMAP)
                    outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
                #else
                    outSurfaceData.normalTS = half3(0,0,1);
                #endif

                //outSurfaceData.occlusion = lerp(1.0h, SSSAOSample.a, _OcclusionStrength);

                #if defined(_MASKMAP)
                    half4 MaskMapSample = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, uv);
                    outSurfaceData.occlusion = MaskMapSample.g; //lerp(1.0h, SSSAOSample.a, _OcclusionStrength);
                    outSurfaceData.shift = MaskMapSample.b;
                #else
                    outSurfaceData.occlusion = 1;
                    outSurfaceData.shift = 0;
                #endif

                outSurfaceData.smoothness = _Smoothness;
                outSurfaceData.emission = 0;
            }

            void InitializeInputData(VertexOutput input, half3 normalTS, out InputData inputData)
            {
                inputData = (InputData)0;
                inputData.positionWS = input.positionWS;
                //#ifdef _NORMALMAP
                    half3 viewDirWS = half3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
                    inputData.normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
                //#else
                //    half3 viewDirWS = input.viewDirWS;
                //    inputData.normalWS = input.normalWS;
                //#endif

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

            half4 LitPassFragment(VertexOutput input
                #if defined(_ENABLEVFACE)
                    , half facing : VFACE
                #endif
                ) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

            //  Get the surface description
                SurfaceDescription surfaceData;
                //InitializeHairLitSurfaceData(input.uv.xy, input.screenPos, input.fade, input.color, surfaceData);
                InitializeHairLitSurfaceData(input.uv.xy, input.color, surfaceData);

            //  Handle VFACE
                #if defined(_ENABLEVFACE)
                    surfaceData.normalTS.z *= facing;
                #endif

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
                half4 color = LuxLWRPHairFragment(
                    inputData,
                    input.tangentWS.xyz,
                    //(_StrandDir == 0) ? input.bitangentWS.xyz : input.tangentWS.xyz,
                    input.bitangentWS.xyz,
                    surfaceData.albedo * lerp(_SecondaryColor.rgb, _BaseColor.rgb, input.color.a), //_BaseColor.rgb,
                    surfaceData.specular,
                    surfaceData.occlusion,
                    surfaceData.emission,
                    surfaceData.albedo, // noise
                    _SpecularShift * surfaceData.shift,
                    _SpecularTint,
                    _SpecularExponent * surfaceData.smoothness,
                    _SecondarySpecularShift * surfaceData.shift,
                    _SecondarySpecularTint,
                    _SecondarySpecularExponent * surfaceData.smoothness,

                    _RimTransmissionIntensity,
                    _AmbientReflection
                );
                
                color.a =  surfaceData.alpha;   

            //  Add fog
                color.rgb = MixFog(color.rgb, inputData.fogCoord);

                return color;
            }

#endif