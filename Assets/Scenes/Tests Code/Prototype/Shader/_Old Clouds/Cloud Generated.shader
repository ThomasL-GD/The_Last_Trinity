Shader "Cloud"
{
    Properties
    {
        Vector4_88e977257a114610b6ab7b541f4f3601("RotateProjection", Vector) = (1, 0, 0, 90)
        Vector1_b11fb5b9b0d04beb860e34a11359a2a1("Noise Scale", Float) = 0.1
        Vector1_fb0dafa4b52c44978933c3b768b3824b("Noise Speed", Float) = 0.1
        Vector1_32393eb9d555437685c764966eb12914("Noise Height", Float) = 50
        Vector4_5a5ab4f1e88a4f0daa7e1666440b102d("Noise Remap", Vector) = (0, 1, -1, 1)
        Color_24c96a6812594de2a681d3f1a4fe5eb1("Color Peak", Color) = (1, 1, 1, 0)
        Color_699599e1fb214013afa4e9107c154503("Color Valley", Color) = (0, 0, 0, 0)
        Vector1_6418af77f3c74440b57f30044ead3d21("Noise Edge Bot", Float) = 0
        Vector1_f89360f4e9e349459d6b59af50c17515("Noise Edge Top", Float) = 0
        Vector1_314df1cf359b431d86cfe61772b70856("Noise Power", Float) = 2
        Vector1_d2fdeddc5fa944b3895e4372b3981a13("Base Scale", Float) = 5
        Vector1_4c31c067e6da4e8fb0218aa823355d04("Base Speed", Float) = 0.2
        Vector1_0b165b42b70147f89838695c6e8f5d02("Base Strenght", Float) = 2
        Vector1_399760d5c87d4e48804f435376d0704d("Emission Strenght", Float) = 2
        Vector1_a46326451a14408db994f28bfdf5b798("Curvature Radius", Float) = 1
        Vector1_7fa6e24aa65042c98d2a987199357dc6("Fresnel Power", Float) = 2
        Vector1_22df991c6afb4a55850398c5b1908e7f("Fresnel Opacity", Float) = 2
        Vector1_6ddbb35793064667917f9cb6903f211d("Fade Depth", Float) = 100
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 TangentSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float3 interp3 : TEXCOORD3;
            #if defined(LIGHTMAP_ON)
            float2 interp4 : TEXCOORD4;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp5 : TEXCOORD5;
            #endif
            float4 interp6 : TEXCOORD6;
            float4 interp7 : TEXCOORD7;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_88e977257a114610b6ab7b541f4f3601;
        float Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
        float Vector1_fb0dafa4b52c44978933c3b768b3824b;
        float Vector1_32393eb9d555437685c764966eb12914;
        float4 Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
        float4 Color_24c96a6812594de2a681d3f1a4fe5eb1;
        float4 Color_699599e1fb214013afa4e9107c154503;
        float Vector1_6418af77f3c74440b57f30044ead3d21;
        float Vector1_f89360f4e9e349459d6b59af50c17515;
        float Vector1_314df1cf359b431d86cfe61772b70856;
        float Vector1_d2fdeddc5fa944b3895e4372b3981a13;
        float Vector1_4c31c067e6da4e8fb0218aa823355d04;
        float Vector1_0b165b42b70147f89838695c6e8f5d02;
        float Vector1_399760d5c87d4e48804f435376d0704d;
        float Vector1_a46326451a14408db994f28bfdf5b798;
        float Vector1_7fa6e24aa65042c98d2a987199357dc6;
        float Vector1_22df991c6afb4a55850398c5b1908e7f;
        float Vector1_6ddbb35793064667917f9cb6903f211d;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2);
            float _Property_535c990566394a8390d6092bfa607e8e_Out_0 = Vector1_a46326451a14408db994f28bfdf5b798;
            float _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2;
            Unity_Divide_float(_Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2, _Property_535c990566394a8390d6092bfa607e8e_Out_0, _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2);
            float _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2;
            Unity_Power_float(_Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2, 3, _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2);
            float3 _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2.xxx), _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2);
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float3 _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxx), _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2);
            float _Property_0611e1cc5f55410486dca728b061efaf_Out_0 = Vector1_32393eb9d555437685c764966eb12914;
            float3 _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2;
            Unity_Multiply_float(_Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2, (_Property_0611e1cc5f55410486dca728b061efaf_Out_0.xxx), _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2);
            float3 _Add_4ccd19eb971b47898ee413055854734b_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2);
            float3 _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            Unity_Add_float3(_Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2, _Add_e7ff0a40f364460384696f81edcb6c74_Out_2);
            description.Position = _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_59872bf6da214f039950a13dfbf07629_Out_0 = Color_699599e1fb214013afa4e9107c154503;
            float4 _Property_0917a6b752264f8aa324e15bcc5c25c9_Out_0 = Color_24c96a6812594de2a681d3f1a4fe5eb1;
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float4 _Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3;
            Unity_Lerp_float4(_Property_59872bf6da214f039950a13dfbf07629_Out_0, _Property_0917a6b752264f8aa324e15bcc5c25c9_Out_0, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxxx), _Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3);
            float _Property_7192c99947114867b2a1aeb127be60fc_Out_0 = Vector1_7fa6e24aa65042c98d2a987199357dc6;
            float _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_7192c99947114867b2a1aeb127be60fc_Out_0, _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3);
            float _Multiply_73ac6b7499a74e928109209f27e70133_Out_2;
            Unity_Multiply_float(_Divide_3cbe7e805116490784cc260cc348248a_Out_2, _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3, _Multiply_73ac6b7499a74e928109209f27e70133_Out_2);
            float _Property_d1cf0f3d046341e481f0a08c9fd422b5_Out_0 = Vector1_22df991c6afb4a55850398c5b1908e7f;
            float _Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2;
            Unity_Multiply_float(_Multiply_73ac6b7499a74e928109209f27e70133_Out_2, _Property_d1cf0f3d046341e481f0a08c9fd422b5_Out_0, _Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2);
            float4 _Add_174642f8883047c18dc504356746f29c_Out_2;
            Unity_Add_float4(_Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3, (_Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2.xxxx), _Add_174642f8883047c18dc504356746f29c_Out_2);
            float _Property_c3a127137e024a1fa1ae33d3c9c1ee5e_Out_0 = Vector1_399760d5c87d4e48804f435376d0704d;
            float4 _Multiply_9faee37184334ff6ba858b1fc2db2904_Out_2;
            Unity_Multiply_float(_Add_174642f8883047c18dc504356746f29c_Out_2, (_Property_c3a127137e024a1fa1ae33d3c9c1ee5e_Out_0.xxxx), _Multiply_9faee37184334ff6ba858b1fc2db2904_Out_2);
            float _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1);
            float4 _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0 = IN.ScreenPosition;
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_R_1 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[0];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_G_2 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[1];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_B_3 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[2];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[3];
            float _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2;
            Unity_Subtract_float(_Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4, 1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2);
            float _Subtract_5f6605fd26704b45918c87119d510a96_Out_2;
            Unity_Subtract_float(_SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2, _Subtract_5f6605fd26704b45918c87119d510a96_Out_2);
            float _Property_39706a7e5c994317a1aa961a5a802df6_Out_0 = Vector1_6ddbb35793064667917f9cb6903f211d;
            float _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2;
            Unity_Divide_float(_Subtract_5f6605fd26704b45918c87119d510a96_Out_2, _Property_39706a7e5c994317a1aa961a5a802df6_Out_0, _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2);
            float _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            Unity_Saturate_float(_Divide_60b0005a76d1453f8b759a903b0ce475_Out_2, _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1);
            surface.BaseColor = (_Add_174642f8883047c18dc504356746f29c_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_9faee37184334ff6ba858b1fc2db2904_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_GBUFFER
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 TangentSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float3 interp3 : TEXCOORD3;
            #if defined(LIGHTMAP_ON)
            float2 interp4 : TEXCOORD4;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp5 : TEXCOORD5;
            #endif
            float4 interp6 : TEXCOORD6;
            float4 interp7 : TEXCOORD7;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_88e977257a114610b6ab7b541f4f3601;
        float Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
        float Vector1_fb0dafa4b52c44978933c3b768b3824b;
        float Vector1_32393eb9d555437685c764966eb12914;
        float4 Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
        float4 Color_24c96a6812594de2a681d3f1a4fe5eb1;
        float4 Color_699599e1fb214013afa4e9107c154503;
        float Vector1_6418af77f3c74440b57f30044ead3d21;
        float Vector1_f89360f4e9e349459d6b59af50c17515;
        float Vector1_314df1cf359b431d86cfe61772b70856;
        float Vector1_d2fdeddc5fa944b3895e4372b3981a13;
        float Vector1_4c31c067e6da4e8fb0218aa823355d04;
        float Vector1_0b165b42b70147f89838695c6e8f5d02;
        float Vector1_399760d5c87d4e48804f435376d0704d;
        float Vector1_a46326451a14408db994f28bfdf5b798;
        float Vector1_7fa6e24aa65042c98d2a987199357dc6;
        float Vector1_22df991c6afb4a55850398c5b1908e7f;
        float Vector1_6ddbb35793064667917f9cb6903f211d;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2);
            float _Property_535c990566394a8390d6092bfa607e8e_Out_0 = Vector1_a46326451a14408db994f28bfdf5b798;
            float _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2;
            Unity_Divide_float(_Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2, _Property_535c990566394a8390d6092bfa607e8e_Out_0, _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2);
            float _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2;
            Unity_Power_float(_Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2, 3, _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2);
            float3 _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2.xxx), _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2);
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float3 _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxx), _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2);
            float _Property_0611e1cc5f55410486dca728b061efaf_Out_0 = Vector1_32393eb9d555437685c764966eb12914;
            float3 _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2;
            Unity_Multiply_float(_Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2, (_Property_0611e1cc5f55410486dca728b061efaf_Out_0.xxx), _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2);
            float3 _Add_4ccd19eb971b47898ee413055854734b_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2);
            float3 _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            Unity_Add_float3(_Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2, _Add_e7ff0a40f364460384696f81edcb6c74_Out_2);
            description.Position = _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_59872bf6da214f039950a13dfbf07629_Out_0 = Color_699599e1fb214013afa4e9107c154503;
            float4 _Property_0917a6b752264f8aa324e15bcc5c25c9_Out_0 = Color_24c96a6812594de2a681d3f1a4fe5eb1;
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float4 _Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3;
            Unity_Lerp_float4(_Property_59872bf6da214f039950a13dfbf07629_Out_0, _Property_0917a6b752264f8aa324e15bcc5c25c9_Out_0, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxxx), _Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3);
            float _Property_7192c99947114867b2a1aeb127be60fc_Out_0 = Vector1_7fa6e24aa65042c98d2a987199357dc6;
            float _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_7192c99947114867b2a1aeb127be60fc_Out_0, _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3);
            float _Multiply_73ac6b7499a74e928109209f27e70133_Out_2;
            Unity_Multiply_float(_Divide_3cbe7e805116490784cc260cc348248a_Out_2, _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3, _Multiply_73ac6b7499a74e928109209f27e70133_Out_2);
            float _Property_d1cf0f3d046341e481f0a08c9fd422b5_Out_0 = Vector1_22df991c6afb4a55850398c5b1908e7f;
            float _Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2;
            Unity_Multiply_float(_Multiply_73ac6b7499a74e928109209f27e70133_Out_2, _Property_d1cf0f3d046341e481f0a08c9fd422b5_Out_0, _Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2);
            float4 _Add_174642f8883047c18dc504356746f29c_Out_2;
            Unity_Add_float4(_Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3, (_Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2.xxxx), _Add_174642f8883047c18dc504356746f29c_Out_2);
            float _Property_c3a127137e024a1fa1ae33d3c9c1ee5e_Out_0 = Vector1_399760d5c87d4e48804f435376d0704d;
            float4 _Multiply_9faee37184334ff6ba858b1fc2db2904_Out_2;
            Unity_Multiply_float(_Add_174642f8883047c18dc504356746f29c_Out_2, (_Property_c3a127137e024a1fa1ae33d3c9c1ee5e_Out_0.xxxx), _Multiply_9faee37184334ff6ba858b1fc2db2904_Out_2);
            float _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1);
            float4 _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0 = IN.ScreenPosition;
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_R_1 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[0];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_G_2 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[1];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_B_3 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[2];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[3];
            float _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2;
            Unity_Subtract_float(_Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4, 1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2);
            float _Subtract_5f6605fd26704b45918c87119d510a96_Out_2;
            Unity_Subtract_float(_SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2, _Subtract_5f6605fd26704b45918c87119d510a96_Out_2);
            float _Property_39706a7e5c994317a1aa961a5a802df6_Out_0 = Vector1_6ddbb35793064667917f9cb6903f211d;
            float _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2;
            Unity_Divide_float(_Subtract_5f6605fd26704b45918c87119d510a96_Out_2, _Property_39706a7e5c994317a1aa961a5a802df6_Out_0, _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2);
            float _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            Unity_Saturate_float(_Divide_60b0005a76d1453f8b759a903b0ce475_Out_2, _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1);
            surface.BaseColor = (_Add_174642f8883047c18dc504356746f29c_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_9faee37184334ff6ba858b1fc2db2904_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_88e977257a114610b6ab7b541f4f3601;
        float Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
        float Vector1_fb0dafa4b52c44978933c3b768b3824b;
        float Vector1_32393eb9d555437685c764966eb12914;
        float4 Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
        float4 Color_24c96a6812594de2a681d3f1a4fe5eb1;
        float4 Color_699599e1fb214013afa4e9107c154503;
        float Vector1_6418af77f3c74440b57f30044ead3d21;
        float Vector1_f89360f4e9e349459d6b59af50c17515;
        float Vector1_314df1cf359b431d86cfe61772b70856;
        float Vector1_d2fdeddc5fa944b3895e4372b3981a13;
        float Vector1_4c31c067e6da4e8fb0218aa823355d04;
        float Vector1_0b165b42b70147f89838695c6e8f5d02;
        float Vector1_399760d5c87d4e48804f435376d0704d;
        float Vector1_a46326451a14408db994f28bfdf5b798;
        float Vector1_7fa6e24aa65042c98d2a987199357dc6;
        float Vector1_22df991c6afb4a55850398c5b1908e7f;
        float Vector1_6ddbb35793064667917f9cb6903f211d;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2);
            float _Property_535c990566394a8390d6092bfa607e8e_Out_0 = Vector1_a46326451a14408db994f28bfdf5b798;
            float _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2;
            Unity_Divide_float(_Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2, _Property_535c990566394a8390d6092bfa607e8e_Out_0, _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2);
            float _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2;
            Unity_Power_float(_Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2, 3, _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2);
            float3 _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2.xxx), _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2);
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float3 _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxx), _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2);
            float _Property_0611e1cc5f55410486dca728b061efaf_Out_0 = Vector1_32393eb9d555437685c764966eb12914;
            float3 _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2;
            Unity_Multiply_float(_Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2, (_Property_0611e1cc5f55410486dca728b061efaf_Out_0.xxx), _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2);
            float3 _Add_4ccd19eb971b47898ee413055854734b_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2);
            float3 _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            Unity_Add_float3(_Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2, _Add_e7ff0a40f364460384696f81edcb6c74_Out_2);
            description.Position = _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1);
            float4 _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0 = IN.ScreenPosition;
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_R_1 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[0];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_G_2 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[1];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_B_3 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[2];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[3];
            float _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2;
            Unity_Subtract_float(_Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4, 1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2);
            float _Subtract_5f6605fd26704b45918c87119d510a96_Out_2;
            Unity_Subtract_float(_SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2, _Subtract_5f6605fd26704b45918c87119d510a96_Out_2);
            float _Property_39706a7e5c994317a1aa961a5a802df6_Out_0 = Vector1_6ddbb35793064667917f9cb6903f211d;
            float _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2;
            Unity_Divide_float(_Subtract_5f6605fd26704b45918c87119d510a96_Out_2, _Property_39706a7e5c994317a1aa961a5a802df6_Out_0, _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2);
            float _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            Unity_Saturate_float(_Divide_60b0005a76d1453f8b759a903b0ce475_Out_2, _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1);
            surface.Alpha = _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_88e977257a114610b6ab7b541f4f3601;
        float Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
        float Vector1_fb0dafa4b52c44978933c3b768b3824b;
        float Vector1_32393eb9d555437685c764966eb12914;
        float4 Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
        float4 Color_24c96a6812594de2a681d3f1a4fe5eb1;
        float4 Color_699599e1fb214013afa4e9107c154503;
        float Vector1_6418af77f3c74440b57f30044ead3d21;
        float Vector1_f89360f4e9e349459d6b59af50c17515;
        float Vector1_314df1cf359b431d86cfe61772b70856;
        float Vector1_d2fdeddc5fa944b3895e4372b3981a13;
        float Vector1_4c31c067e6da4e8fb0218aa823355d04;
        float Vector1_0b165b42b70147f89838695c6e8f5d02;
        float Vector1_399760d5c87d4e48804f435376d0704d;
        float Vector1_a46326451a14408db994f28bfdf5b798;
        float Vector1_7fa6e24aa65042c98d2a987199357dc6;
        float Vector1_22df991c6afb4a55850398c5b1908e7f;
        float Vector1_6ddbb35793064667917f9cb6903f211d;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2);
            float _Property_535c990566394a8390d6092bfa607e8e_Out_0 = Vector1_a46326451a14408db994f28bfdf5b798;
            float _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2;
            Unity_Divide_float(_Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2, _Property_535c990566394a8390d6092bfa607e8e_Out_0, _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2);
            float _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2;
            Unity_Power_float(_Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2, 3, _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2);
            float3 _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2.xxx), _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2);
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float3 _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxx), _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2);
            float _Property_0611e1cc5f55410486dca728b061efaf_Out_0 = Vector1_32393eb9d555437685c764966eb12914;
            float3 _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2;
            Unity_Multiply_float(_Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2, (_Property_0611e1cc5f55410486dca728b061efaf_Out_0.xxx), _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2);
            float3 _Add_4ccd19eb971b47898ee413055854734b_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2);
            float3 _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            Unity_Add_float3(_Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2, _Add_e7ff0a40f364460384696f81edcb6c74_Out_2);
            description.Position = _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1);
            float4 _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0 = IN.ScreenPosition;
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_R_1 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[0];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_G_2 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[1];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_B_3 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[2];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[3];
            float _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2;
            Unity_Subtract_float(_Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4, 1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2);
            float _Subtract_5f6605fd26704b45918c87119d510a96_Out_2;
            Unity_Subtract_float(_SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2, _Subtract_5f6605fd26704b45918c87119d510a96_Out_2);
            float _Property_39706a7e5c994317a1aa961a5a802df6_Out_0 = Vector1_6ddbb35793064667917f9cb6903f211d;
            float _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2;
            Unity_Divide_float(_Subtract_5f6605fd26704b45918c87119d510a96_Out_2, _Property_39706a7e5c994317a1aa961a5a802df6_Out_0, _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2);
            float _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            Unity_Saturate_float(_Divide_60b0005a76d1453f8b759a903b0ce475_Out_2, _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1);
            surface.Alpha = _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_88e977257a114610b6ab7b541f4f3601;
        float Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
        float Vector1_fb0dafa4b52c44978933c3b768b3824b;
        float Vector1_32393eb9d555437685c764966eb12914;
        float4 Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
        float4 Color_24c96a6812594de2a681d3f1a4fe5eb1;
        float4 Color_699599e1fb214013afa4e9107c154503;
        float Vector1_6418af77f3c74440b57f30044ead3d21;
        float Vector1_f89360f4e9e349459d6b59af50c17515;
        float Vector1_314df1cf359b431d86cfe61772b70856;
        float Vector1_d2fdeddc5fa944b3895e4372b3981a13;
        float Vector1_4c31c067e6da4e8fb0218aa823355d04;
        float Vector1_0b165b42b70147f89838695c6e8f5d02;
        float Vector1_399760d5c87d4e48804f435376d0704d;
        float Vector1_a46326451a14408db994f28bfdf5b798;
        float Vector1_7fa6e24aa65042c98d2a987199357dc6;
        float Vector1_22df991c6afb4a55850398c5b1908e7f;
        float Vector1_6ddbb35793064667917f9cb6903f211d;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2);
            float _Property_535c990566394a8390d6092bfa607e8e_Out_0 = Vector1_a46326451a14408db994f28bfdf5b798;
            float _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2;
            Unity_Divide_float(_Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2, _Property_535c990566394a8390d6092bfa607e8e_Out_0, _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2);
            float _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2;
            Unity_Power_float(_Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2, 3, _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2);
            float3 _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2.xxx), _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2);
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float3 _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxx), _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2);
            float _Property_0611e1cc5f55410486dca728b061efaf_Out_0 = Vector1_32393eb9d555437685c764966eb12914;
            float3 _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2;
            Unity_Multiply_float(_Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2, (_Property_0611e1cc5f55410486dca728b061efaf_Out_0.xxx), _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2);
            float3 _Add_4ccd19eb971b47898ee413055854734b_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2);
            float3 _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            Unity_Add_float3(_Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2, _Add_e7ff0a40f364460384696f81edcb6c74_Out_2);
            description.Position = _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1);
            float4 _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0 = IN.ScreenPosition;
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_R_1 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[0];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_G_2 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[1];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_B_3 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[2];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[3];
            float _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2;
            Unity_Subtract_float(_Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4, 1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2);
            float _Subtract_5f6605fd26704b45918c87119d510a96_Out_2;
            Unity_Subtract_float(_SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2, _Subtract_5f6605fd26704b45918c87119d510a96_Out_2);
            float _Property_39706a7e5c994317a1aa961a5a802df6_Out_0 = Vector1_6ddbb35793064667917f9cb6903f211d;
            float _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2;
            Unity_Divide_float(_Subtract_5f6605fd26704b45918c87119d510a96_Out_2, _Property_39706a7e5c994317a1aa961a5a802df6_Out_0, _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2);
            float _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            Unity_Saturate_float(_Divide_60b0005a76d1453f8b759a903b0ce475_Out_2, _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float3 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_88e977257a114610b6ab7b541f4f3601;
        float Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
        float Vector1_fb0dafa4b52c44978933c3b768b3824b;
        float Vector1_32393eb9d555437685c764966eb12914;
        float4 Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
        float4 Color_24c96a6812594de2a681d3f1a4fe5eb1;
        float4 Color_699599e1fb214013afa4e9107c154503;
        float Vector1_6418af77f3c74440b57f30044ead3d21;
        float Vector1_f89360f4e9e349459d6b59af50c17515;
        float Vector1_314df1cf359b431d86cfe61772b70856;
        float Vector1_d2fdeddc5fa944b3895e4372b3981a13;
        float Vector1_4c31c067e6da4e8fb0218aa823355d04;
        float Vector1_0b165b42b70147f89838695c6e8f5d02;
        float Vector1_399760d5c87d4e48804f435376d0704d;
        float Vector1_a46326451a14408db994f28bfdf5b798;
        float Vector1_7fa6e24aa65042c98d2a987199357dc6;
        float Vector1_22df991c6afb4a55850398c5b1908e7f;
        float Vector1_6ddbb35793064667917f9cb6903f211d;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2);
            float _Property_535c990566394a8390d6092bfa607e8e_Out_0 = Vector1_a46326451a14408db994f28bfdf5b798;
            float _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2;
            Unity_Divide_float(_Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2, _Property_535c990566394a8390d6092bfa607e8e_Out_0, _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2);
            float _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2;
            Unity_Power_float(_Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2, 3, _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2);
            float3 _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2.xxx), _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2);
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float3 _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxx), _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2);
            float _Property_0611e1cc5f55410486dca728b061efaf_Out_0 = Vector1_32393eb9d555437685c764966eb12914;
            float3 _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2;
            Unity_Multiply_float(_Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2, (_Property_0611e1cc5f55410486dca728b061efaf_Out_0.xxx), _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2);
            float3 _Add_4ccd19eb971b47898ee413055854734b_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2);
            float3 _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            Unity_Add_float3(_Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2, _Add_e7ff0a40f364460384696f81edcb6c74_Out_2);
            description.Position = _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_59872bf6da214f039950a13dfbf07629_Out_0 = Color_699599e1fb214013afa4e9107c154503;
            float4 _Property_0917a6b752264f8aa324e15bcc5c25c9_Out_0 = Color_24c96a6812594de2a681d3f1a4fe5eb1;
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float4 _Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3;
            Unity_Lerp_float4(_Property_59872bf6da214f039950a13dfbf07629_Out_0, _Property_0917a6b752264f8aa324e15bcc5c25c9_Out_0, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxxx), _Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3);
            float _Property_7192c99947114867b2a1aeb127be60fc_Out_0 = Vector1_7fa6e24aa65042c98d2a987199357dc6;
            float _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_7192c99947114867b2a1aeb127be60fc_Out_0, _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3);
            float _Multiply_73ac6b7499a74e928109209f27e70133_Out_2;
            Unity_Multiply_float(_Divide_3cbe7e805116490784cc260cc348248a_Out_2, _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3, _Multiply_73ac6b7499a74e928109209f27e70133_Out_2);
            float _Property_d1cf0f3d046341e481f0a08c9fd422b5_Out_0 = Vector1_22df991c6afb4a55850398c5b1908e7f;
            float _Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2;
            Unity_Multiply_float(_Multiply_73ac6b7499a74e928109209f27e70133_Out_2, _Property_d1cf0f3d046341e481f0a08c9fd422b5_Out_0, _Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2);
            float4 _Add_174642f8883047c18dc504356746f29c_Out_2;
            Unity_Add_float4(_Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3, (_Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2.xxxx), _Add_174642f8883047c18dc504356746f29c_Out_2);
            float _Property_c3a127137e024a1fa1ae33d3c9c1ee5e_Out_0 = Vector1_399760d5c87d4e48804f435376d0704d;
            float4 _Multiply_9faee37184334ff6ba858b1fc2db2904_Out_2;
            Unity_Multiply_float(_Add_174642f8883047c18dc504356746f29c_Out_2, (_Property_c3a127137e024a1fa1ae33d3c9c1ee5e_Out_0.xxxx), _Multiply_9faee37184334ff6ba858b1fc2db2904_Out_2);
            float _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1);
            float4 _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0 = IN.ScreenPosition;
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_R_1 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[0];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_G_2 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[1];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_B_3 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[2];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[3];
            float _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2;
            Unity_Subtract_float(_Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4, 1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2);
            float _Subtract_5f6605fd26704b45918c87119d510a96_Out_2;
            Unity_Subtract_float(_SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2, _Subtract_5f6605fd26704b45918c87119d510a96_Out_2);
            float _Property_39706a7e5c994317a1aa961a5a802df6_Out_0 = Vector1_6ddbb35793064667917f9cb6903f211d;
            float _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2;
            Unity_Divide_float(_Subtract_5f6605fd26704b45918c87119d510a96_Out_2, _Property_39706a7e5c994317a1aa961a5a802df6_Out_0, _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2);
            float _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            Unity_Saturate_float(_Divide_60b0005a76d1453f8b759a903b0ce475_Out_2, _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1);
            surface.BaseColor = (_Add_174642f8883047c18dc504356746f29c_Out_2.xyz);
            surface.Emission = (_Multiply_9faee37184334ff6ba858b1fc2db2904_Out_2.xyz);
            surface.Alpha = _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float3 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_88e977257a114610b6ab7b541f4f3601;
        float Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
        float Vector1_fb0dafa4b52c44978933c3b768b3824b;
        float Vector1_32393eb9d555437685c764966eb12914;
        float4 Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
        float4 Color_24c96a6812594de2a681d3f1a4fe5eb1;
        float4 Color_699599e1fb214013afa4e9107c154503;
        float Vector1_6418af77f3c74440b57f30044ead3d21;
        float Vector1_f89360f4e9e349459d6b59af50c17515;
        float Vector1_314df1cf359b431d86cfe61772b70856;
        float Vector1_d2fdeddc5fa944b3895e4372b3981a13;
        float Vector1_4c31c067e6da4e8fb0218aa823355d04;
        float Vector1_0b165b42b70147f89838695c6e8f5d02;
        float Vector1_399760d5c87d4e48804f435376d0704d;
        float Vector1_a46326451a14408db994f28bfdf5b798;
        float Vector1_7fa6e24aa65042c98d2a987199357dc6;
        float Vector1_22df991c6afb4a55850398c5b1908e7f;
        float Vector1_6ddbb35793064667917f9cb6903f211d;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2);
            float _Property_535c990566394a8390d6092bfa607e8e_Out_0 = Vector1_a46326451a14408db994f28bfdf5b798;
            float _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2;
            Unity_Divide_float(_Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2, _Property_535c990566394a8390d6092bfa607e8e_Out_0, _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2);
            float _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2;
            Unity_Power_float(_Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2, 3, _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2);
            float3 _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2.xxx), _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2);
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float3 _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxx), _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2);
            float _Property_0611e1cc5f55410486dca728b061efaf_Out_0 = Vector1_32393eb9d555437685c764966eb12914;
            float3 _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2;
            Unity_Multiply_float(_Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2, (_Property_0611e1cc5f55410486dca728b061efaf_Out_0.xxx), _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2);
            float3 _Add_4ccd19eb971b47898ee413055854734b_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2);
            float3 _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            Unity_Add_float3(_Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2, _Add_e7ff0a40f364460384696f81edcb6c74_Out_2);
            description.Position = _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_59872bf6da214f039950a13dfbf07629_Out_0 = Color_699599e1fb214013afa4e9107c154503;
            float4 _Property_0917a6b752264f8aa324e15bcc5c25c9_Out_0 = Color_24c96a6812594de2a681d3f1a4fe5eb1;
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float4 _Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3;
            Unity_Lerp_float4(_Property_59872bf6da214f039950a13dfbf07629_Out_0, _Property_0917a6b752264f8aa324e15bcc5c25c9_Out_0, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxxx), _Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3);
            float _Property_7192c99947114867b2a1aeb127be60fc_Out_0 = Vector1_7fa6e24aa65042c98d2a987199357dc6;
            float _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_7192c99947114867b2a1aeb127be60fc_Out_0, _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3);
            float _Multiply_73ac6b7499a74e928109209f27e70133_Out_2;
            Unity_Multiply_float(_Divide_3cbe7e805116490784cc260cc348248a_Out_2, _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3, _Multiply_73ac6b7499a74e928109209f27e70133_Out_2);
            float _Property_d1cf0f3d046341e481f0a08c9fd422b5_Out_0 = Vector1_22df991c6afb4a55850398c5b1908e7f;
            float _Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2;
            Unity_Multiply_float(_Multiply_73ac6b7499a74e928109209f27e70133_Out_2, _Property_d1cf0f3d046341e481f0a08c9fd422b5_Out_0, _Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2);
            float4 _Add_174642f8883047c18dc504356746f29c_Out_2;
            Unity_Add_float4(_Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3, (_Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2.xxxx), _Add_174642f8883047c18dc504356746f29c_Out_2);
            float _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1);
            float4 _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0 = IN.ScreenPosition;
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_R_1 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[0];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_G_2 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[1];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_B_3 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[2];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[3];
            float _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2;
            Unity_Subtract_float(_Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4, 1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2);
            float _Subtract_5f6605fd26704b45918c87119d510a96_Out_2;
            Unity_Subtract_float(_SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2, _Subtract_5f6605fd26704b45918c87119d510a96_Out_2);
            float _Property_39706a7e5c994317a1aa961a5a802df6_Out_0 = Vector1_6ddbb35793064667917f9cb6903f211d;
            float _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2;
            Unity_Divide_float(_Subtract_5f6605fd26704b45918c87119d510a96_Out_2, _Property_39706a7e5c994317a1aa961a5a802df6_Out_0, _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2);
            float _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            Unity_Saturate_float(_Divide_60b0005a76d1453f8b759a903b0ce475_Out_2, _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1);
            surface.BaseColor = (_Add_174642f8883047c18dc504356746f29c_Out_2.xyz);
            surface.Alpha = _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 TangentSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float3 interp3 : TEXCOORD3;
            #if defined(LIGHTMAP_ON)
            float2 interp4 : TEXCOORD4;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp5 : TEXCOORD5;
            #endif
            float4 interp6 : TEXCOORD6;
            float4 interp7 : TEXCOORD7;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_88e977257a114610b6ab7b541f4f3601;
        float Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
        float Vector1_fb0dafa4b52c44978933c3b768b3824b;
        float Vector1_32393eb9d555437685c764966eb12914;
        float4 Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
        float4 Color_24c96a6812594de2a681d3f1a4fe5eb1;
        float4 Color_699599e1fb214013afa4e9107c154503;
        float Vector1_6418af77f3c74440b57f30044ead3d21;
        float Vector1_f89360f4e9e349459d6b59af50c17515;
        float Vector1_314df1cf359b431d86cfe61772b70856;
        float Vector1_d2fdeddc5fa944b3895e4372b3981a13;
        float Vector1_4c31c067e6da4e8fb0218aa823355d04;
        float Vector1_0b165b42b70147f89838695c6e8f5d02;
        float Vector1_399760d5c87d4e48804f435376d0704d;
        float Vector1_a46326451a14408db994f28bfdf5b798;
        float Vector1_7fa6e24aa65042c98d2a987199357dc6;
        float Vector1_22df991c6afb4a55850398c5b1908e7f;
        float Vector1_6ddbb35793064667917f9cb6903f211d;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2);
            float _Property_535c990566394a8390d6092bfa607e8e_Out_0 = Vector1_a46326451a14408db994f28bfdf5b798;
            float _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2;
            Unity_Divide_float(_Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2, _Property_535c990566394a8390d6092bfa607e8e_Out_0, _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2);
            float _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2;
            Unity_Power_float(_Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2, 3, _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2);
            float3 _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2.xxx), _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2);
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float3 _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxx), _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2);
            float _Property_0611e1cc5f55410486dca728b061efaf_Out_0 = Vector1_32393eb9d555437685c764966eb12914;
            float3 _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2;
            Unity_Multiply_float(_Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2, (_Property_0611e1cc5f55410486dca728b061efaf_Out_0.xxx), _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2);
            float3 _Add_4ccd19eb971b47898ee413055854734b_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2);
            float3 _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            Unity_Add_float3(_Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2, _Add_e7ff0a40f364460384696f81edcb6c74_Out_2);
            description.Position = _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_59872bf6da214f039950a13dfbf07629_Out_0 = Color_699599e1fb214013afa4e9107c154503;
            float4 _Property_0917a6b752264f8aa324e15bcc5c25c9_Out_0 = Color_24c96a6812594de2a681d3f1a4fe5eb1;
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float4 _Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3;
            Unity_Lerp_float4(_Property_59872bf6da214f039950a13dfbf07629_Out_0, _Property_0917a6b752264f8aa324e15bcc5c25c9_Out_0, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxxx), _Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3);
            float _Property_7192c99947114867b2a1aeb127be60fc_Out_0 = Vector1_7fa6e24aa65042c98d2a987199357dc6;
            float _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_7192c99947114867b2a1aeb127be60fc_Out_0, _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3);
            float _Multiply_73ac6b7499a74e928109209f27e70133_Out_2;
            Unity_Multiply_float(_Divide_3cbe7e805116490784cc260cc348248a_Out_2, _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3, _Multiply_73ac6b7499a74e928109209f27e70133_Out_2);
            float _Property_d1cf0f3d046341e481f0a08c9fd422b5_Out_0 = Vector1_22df991c6afb4a55850398c5b1908e7f;
            float _Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2;
            Unity_Multiply_float(_Multiply_73ac6b7499a74e928109209f27e70133_Out_2, _Property_d1cf0f3d046341e481f0a08c9fd422b5_Out_0, _Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2);
            float4 _Add_174642f8883047c18dc504356746f29c_Out_2;
            Unity_Add_float4(_Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3, (_Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2.xxxx), _Add_174642f8883047c18dc504356746f29c_Out_2);
            float _Property_c3a127137e024a1fa1ae33d3c9c1ee5e_Out_0 = Vector1_399760d5c87d4e48804f435376d0704d;
            float4 _Multiply_9faee37184334ff6ba858b1fc2db2904_Out_2;
            Unity_Multiply_float(_Add_174642f8883047c18dc504356746f29c_Out_2, (_Property_c3a127137e024a1fa1ae33d3c9c1ee5e_Out_0.xxxx), _Multiply_9faee37184334ff6ba858b1fc2db2904_Out_2);
            float _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1);
            float4 _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0 = IN.ScreenPosition;
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_R_1 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[0];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_G_2 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[1];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_B_3 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[2];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[3];
            float _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2;
            Unity_Subtract_float(_Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4, 1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2);
            float _Subtract_5f6605fd26704b45918c87119d510a96_Out_2;
            Unity_Subtract_float(_SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2, _Subtract_5f6605fd26704b45918c87119d510a96_Out_2);
            float _Property_39706a7e5c994317a1aa961a5a802df6_Out_0 = Vector1_6ddbb35793064667917f9cb6903f211d;
            float _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2;
            Unity_Divide_float(_Subtract_5f6605fd26704b45918c87119d510a96_Out_2, _Property_39706a7e5c994317a1aa961a5a802df6_Out_0, _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2);
            float _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            Unity_Saturate_float(_Divide_60b0005a76d1453f8b759a903b0ce475_Out_2, _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1);
            surface.BaseColor = (_Add_174642f8883047c18dc504356746f29c_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_9faee37184334ff6ba858b1fc2db2904_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_88e977257a114610b6ab7b541f4f3601;
        float Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
        float Vector1_fb0dafa4b52c44978933c3b768b3824b;
        float Vector1_32393eb9d555437685c764966eb12914;
        float4 Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
        float4 Color_24c96a6812594de2a681d3f1a4fe5eb1;
        float4 Color_699599e1fb214013afa4e9107c154503;
        float Vector1_6418af77f3c74440b57f30044ead3d21;
        float Vector1_f89360f4e9e349459d6b59af50c17515;
        float Vector1_314df1cf359b431d86cfe61772b70856;
        float Vector1_d2fdeddc5fa944b3895e4372b3981a13;
        float Vector1_4c31c067e6da4e8fb0218aa823355d04;
        float Vector1_0b165b42b70147f89838695c6e8f5d02;
        float Vector1_399760d5c87d4e48804f435376d0704d;
        float Vector1_a46326451a14408db994f28bfdf5b798;
        float Vector1_7fa6e24aa65042c98d2a987199357dc6;
        float Vector1_22df991c6afb4a55850398c5b1908e7f;
        float Vector1_6ddbb35793064667917f9cb6903f211d;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2);
            float _Property_535c990566394a8390d6092bfa607e8e_Out_0 = Vector1_a46326451a14408db994f28bfdf5b798;
            float _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2;
            Unity_Divide_float(_Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2, _Property_535c990566394a8390d6092bfa607e8e_Out_0, _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2);
            float _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2;
            Unity_Power_float(_Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2, 3, _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2);
            float3 _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2.xxx), _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2);
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float3 _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxx), _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2);
            float _Property_0611e1cc5f55410486dca728b061efaf_Out_0 = Vector1_32393eb9d555437685c764966eb12914;
            float3 _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2;
            Unity_Multiply_float(_Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2, (_Property_0611e1cc5f55410486dca728b061efaf_Out_0.xxx), _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2);
            float3 _Add_4ccd19eb971b47898ee413055854734b_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2);
            float3 _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            Unity_Add_float3(_Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2, _Add_e7ff0a40f364460384696f81edcb6c74_Out_2);
            description.Position = _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1);
            float4 _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0 = IN.ScreenPosition;
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_R_1 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[0];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_G_2 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[1];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_B_3 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[2];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[3];
            float _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2;
            Unity_Subtract_float(_Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4, 1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2);
            float _Subtract_5f6605fd26704b45918c87119d510a96_Out_2;
            Unity_Subtract_float(_SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2, _Subtract_5f6605fd26704b45918c87119d510a96_Out_2);
            float _Property_39706a7e5c994317a1aa961a5a802df6_Out_0 = Vector1_6ddbb35793064667917f9cb6903f211d;
            float _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2;
            Unity_Divide_float(_Subtract_5f6605fd26704b45918c87119d510a96_Out_2, _Property_39706a7e5c994317a1aa961a5a802df6_Out_0, _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2);
            float _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            Unity_Saturate_float(_Divide_60b0005a76d1453f8b759a903b0ce475_Out_2, _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1);
            surface.Alpha = _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_88e977257a114610b6ab7b541f4f3601;
        float Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
        float Vector1_fb0dafa4b52c44978933c3b768b3824b;
        float Vector1_32393eb9d555437685c764966eb12914;
        float4 Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
        float4 Color_24c96a6812594de2a681d3f1a4fe5eb1;
        float4 Color_699599e1fb214013afa4e9107c154503;
        float Vector1_6418af77f3c74440b57f30044ead3d21;
        float Vector1_f89360f4e9e349459d6b59af50c17515;
        float Vector1_314df1cf359b431d86cfe61772b70856;
        float Vector1_d2fdeddc5fa944b3895e4372b3981a13;
        float Vector1_4c31c067e6da4e8fb0218aa823355d04;
        float Vector1_0b165b42b70147f89838695c6e8f5d02;
        float Vector1_399760d5c87d4e48804f435376d0704d;
        float Vector1_a46326451a14408db994f28bfdf5b798;
        float Vector1_7fa6e24aa65042c98d2a987199357dc6;
        float Vector1_22df991c6afb4a55850398c5b1908e7f;
        float Vector1_6ddbb35793064667917f9cb6903f211d;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2);
            float _Property_535c990566394a8390d6092bfa607e8e_Out_0 = Vector1_a46326451a14408db994f28bfdf5b798;
            float _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2;
            Unity_Divide_float(_Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2, _Property_535c990566394a8390d6092bfa607e8e_Out_0, _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2);
            float _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2;
            Unity_Power_float(_Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2, 3, _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2);
            float3 _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2.xxx), _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2);
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float3 _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxx), _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2);
            float _Property_0611e1cc5f55410486dca728b061efaf_Out_0 = Vector1_32393eb9d555437685c764966eb12914;
            float3 _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2;
            Unity_Multiply_float(_Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2, (_Property_0611e1cc5f55410486dca728b061efaf_Out_0.xxx), _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2);
            float3 _Add_4ccd19eb971b47898ee413055854734b_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2);
            float3 _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            Unity_Add_float3(_Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2, _Add_e7ff0a40f364460384696f81edcb6c74_Out_2);
            description.Position = _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1);
            float4 _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0 = IN.ScreenPosition;
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_R_1 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[0];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_G_2 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[1];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_B_3 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[2];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[3];
            float _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2;
            Unity_Subtract_float(_Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4, 1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2);
            float _Subtract_5f6605fd26704b45918c87119d510a96_Out_2;
            Unity_Subtract_float(_SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2, _Subtract_5f6605fd26704b45918c87119d510a96_Out_2);
            float _Property_39706a7e5c994317a1aa961a5a802df6_Out_0 = Vector1_6ddbb35793064667917f9cb6903f211d;
            float _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2;
            Unity_Divide_float(_Subtract_5f6605fd26704b45918c87119d510a96_Out_2, _Property_39706a7e5c994317a1aa961a5a802df6_Out_0, _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2);
            float _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            Unity_Saturate_float(_Divide_60b0005a76d1453f8b759a903b0ce475_Out_2, _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1);
            surface.Alpha = _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_88e977257a114610b6ab7b541f4f3601;
        float Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
        float Vector1_fb0dafa4b52c44978933c3b768b3824b;
        float Vector1_32393eb9d555437685c764966eb12914;
        float4 Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
        float4 Color_24c96a6812594de2a681d3f1a4fe5eb1;
        float4 Color_699599e1fb214013afa4e9107c154503;
        float Vector1_6418af77f3c74440b57f30044ead3d21;
        float Vector1_f89360f4e9e349459d6b59af50c17515;
        float Vector1_314df1cf359b431d86cfe61772b70856;
        float Vector1_d2fdeddc5fa944b3895e4372b3981a13;
        float Vector1_4c31c067e6da4e8fb0218aa823355d04;
        float Vector1_0b165b42b70147f89838695c6e8f5d02;
        float Vector1_399760d5c87d4e48804f435376d0704d;
        float Vector1_a46326451a14408db994f28bfdf5b798;
        float Vector1_7fa6e24aa65042c98d2a987199357dc6;
        float Vector1_22df991c6afb4a55850398c5b1908e7f;
        float Vector1_6ddbb35793064667917f9cb6903f211d;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2);
            float _Property_535c990566394a8390d6092bfa607e8e_Out_0 = Vector1_a46326451a14408db994f28bfdf5b798;
            float _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2;
            Unity_Divide_float(_Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2, _Property_535c990566394a8390d6092bfa607e8e_Out_0, _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2);
            float _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2;
            Unity_Power_float(_Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2, 3, _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2);
            float3 _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2.xxx), _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2);
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float3 _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxx), _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2);
            float _Property_0611e1cc5f55410486dca728b061efaf_Out_0 = Vector1_32393eb9d555437685c764966eb12914;
            float3 _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2;
            Unity_Multiply_float(_Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2, (_Property_0611e1cc5f55410486dca728b061efaf_Out_0.xxx), _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2);
            float3 _Add_4ccd19eb971b47898ee413055854734b_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2);
            float3 _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            Unity_Add_float3(_Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2, _Add_e7ff0a40f364460384696f81edcb6c74_Out_2);
            description.Position = _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1);
            float4 _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0 = IN.ScreenPosition;
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_R_1 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[0];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_G_2 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[1];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_B_3 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[2];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[3];
            float _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2;
            Unity_Subtract_float(_Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4, 1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2);
            float _Subtract_5f6605fd26704b45918c87119d510a96_Out_2;
            Unity_Subtract_float(_SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2, _Subtract_5f6605fd26704b45918c87119d510a96_Out_2);
            float _Property_39706a7e5c994317a1aa961a5a802df6_Out_0 = Vector1_6ddbb35793064667917f9cb6903f211d;
            float _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2;
            Unity_Divide_float(_Subtract_5f6605fd26704b45918c87119d510a96_Out_2, _Property_39706a7e5c994317a1aa961a5a802df6_Out_0, _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2);
            float _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            Unity_Saturate_float(_Divide_60b0005a76d1453f8b759a903b0ce475_Out_2, _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float3 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_88e977257a114610b6ab7b541f4f3601;
        float Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
        float Vector1_fb0dafa4b52c44978933c3b768b3824b;
        float Vector1_32393eb9d555437685c764966eb12914;
        float4 Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
        float4 Color_24c96a6812594de2a681d3f1a4fe5eb1;
        float4 Color_699599e1fb214013afa4e9107c154503;
        float Vector1_6418af77f3c74440b57f30044ead3d21;
        float Vector1_f89360f4e9e349459d6b59af50c17515;
        float Vector1_314df1cf359b431d86cfe61772b70856;
        float Vector1_d2fdeddc5fa944b3895e4372b3981a13;
        float Vector1_4c31c067e6da4e8fb0218aa823355d04;
        float Vector1_0b165b42b70147f89838695c6e8f5d02;
        float Vector1_399760d5c87d4e48804f435376d0704d;
        float Vector1_a46326451a14408db994f28bfdf5b798;
        float Vector1_7fa6e24aa65042c98d2a987199357dc6;
        float Vector1_22df991c6afb4a55850398c5b1908e7f;
        float Vector1_6ddbb35793064667917f9cb6903f211d;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2);
            float _Property_535c990566394a8390d6092bfa607e8e_Out_0 = Vector1_a46326451a14408db994f28bfdf5b798;
            float _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2;
            Unity_Divide_float(_Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2, _Property_535c990566394a8390d6092bfa607e8e_Out_0, _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2);
            float _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2;
            Unity_Power_float(_Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2, 3, _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2);
            float3 _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2.xxx), _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2);
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float3 _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxx), _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2);
            float _Property_0611e1cc5f55410486dca728b061efaf_Out_0 = Vector1_32393eb9d555437685c764966eb12914;
            float3 _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2;
            Unity_Multiply_float(_Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2, (_Property_0611e1cc5f55410486dca728b061efaf_Out_0.xxx), _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2);
            float3 _Add_4ccd19eb971b47898ee413055854734b_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2);
            float3 _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            Unity_Add_float3(_Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2, _Add_e7ff0a40f364460384696f81edcb6c74_Out_2);
            description.Position = _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_59872bf6da214f039950a13dfbf07629_Out_0 = Color_699599e1fb214013afa4e9107c154503;
            float4 _Property_0917a6b752264f8aa324e15bcc5c25c9_Out_0 = Color_24c96a6812594de2a681d3f1a4fe5eb1;
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float4 _Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3;
            Unity_Lerp_float4(_Property_59872bf6da214f039950a13dfbf07629_Out_0, _Property_0917a6b752264f8aa324e15bcc5c25c9_Out_0, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxxx), _Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3);
            float _Property_7192c99947114867b2a1aeb127be60fc_Out_0 = Vector1_7fa6e24aa65042c98d2a987199357dc6;
            float _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_7192c99947114867b2a1aeb127be60fc_Out_0, _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3);
            float _Multiply_73ac6b7499a74e928109209f27e70133_Out_2;
            Unity_Multiply_float(_Divide_3cbe7e805116490784cc260cc348248a_Out_2, _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3, _Multiply_73ac6b7499a74e928109209f27e70133_Out_2);
            float _Property_d1cf0f3d046341e481f0a08c9fd422b5_Out_0 = Vector1_22df991c6afb4a55850398c5b1908e7f;
            float _Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2;
            Unity_Multiply_float(_Multiply_73ac6b7499a74e928109209f27e70133_Out_2, _Property_d1cf0f3d046341e481f0a08c9fd422b5_Out_0, _Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2);
            float4 _Add_174642f8883047c18dc504356746f29c_Out_2;
            Unity_Add_float4(_Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3, (_Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2.xxxx), _Add_174642f8883047c18dc504356746f29c_Out_2);
            float _Property_c3a127137e024a1fa1ae33d3c9c1ee5e_Out_0 = Vector1_399760d5c87d4e48804f435376d0704d;
            float4 _Multiply_9faee37184334ff6ba858b1fc2db2904_Out_2;
            Unity_Multiply_float(_Add_174642f8883047c18dc504356746f29c_Out_2, (_Property_c3a127137e024a1fa1ae33d3c9c1ee5e_Out_0.xxxx), _Multiply_9faee37184334ff6ba858b1fc2db2904_Out_2);
            float _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1);
            float4 _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0 = IN.ScreenPosition;
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_R_1 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[0];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_G_2 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[1];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_B_3 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[2];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[3];
            float _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2;
            Unity_Subtract_float(_Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4, 1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2);
            float _Subtract_5f6605fd26704b45918c87119d510a96_Out_2;
            Unity_Subtract_float(_SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2, _Subtract_5f6605fd26704b45918c87119d510a96_Out_2);
            float _Property_39706a7e5c994317a1aa961a5a802df6_Out_0 = Vector1_6ddbb35793064667917f9cb6903f211d;
            float _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2;
            Unity_Divide_float(_Subtract_5f6605fd26704b45918c87119d510a96_Out_2, _Property_39706a7e5c994317a1aa961a5a802df6_Out_0, _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2);
            float _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            Unity_Saturate_float(_Divide_60b0005a76d1453f8b759a903b0ce475_Out_2, _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1);
            surface.BaseColor = (_Add_174642f8883047c18dc504356746f29c_Out_2.xyz);
            surface.Emission = (_Multiply_9faee37184334ff6ba858b1fc2db2904_Out_2.xyz);
            surface.Alpha = _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float3 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_88e977257a114610b6ab7b541f4f3601;
        float Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
        float Vector1_fb0dafa4b52c44978933c3b768b3824b;
        float Vector1_32393eb9d555437685c764966eb12914;
        float4 Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
        float4 Color_24c96a6812594de2a681d3f1a4fe5eb1;
        float4 Color_699599e1fb214013afa4e9107c154503;
        float Vector1_6418af77f3c74440b57f30044ead3d21;
        float Vector1_f89360f4e9e349459d6b59af50c17515;
        float Vector1_314df1cf359b431d86cfe61772b70856;
        float Vector1_d2fdeddc5fa944b3895e4372b3981a13;
        float Vector1_4c31c067e6da4e8fb0218aa823355d04;
        float Vector1_0b165b42b70147f89838695c6e8f5d02;
        float Vector1_399760d5c87d4e48804f435376d0704d;
        float Vector1_a46326451a14408db994f28bfdf5b798;
        float Vector1_7fa6e24aa65042c98d2a987199357dc6;
        float Vector1_22df991c6afb4a55850398c5b1908e7f;
        float Vector1_6ddbb35793064667917f9cb6903f211d;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2);
            float _Property_535c990566394a8390d6092bfa607e8e_Out_0 = Vector1_a46326451a14408db994f28bfdf5b798;
            float _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2;
            Unity_Divide_float(_Distance_bbf7ef2ac3fe4b95a9263769793c0ce1_Out_2, _Property_535c990566394a8390d6092bfa607e8e_Out_0, _Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2);
            float _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2;
            Unity_Power_float(_Divide_d5aee22c300b4a738ffb88d9c227cc94_Out_2, 3, _Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2);
            float3 _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_6871d06e622b456ab60270d5f9eb3bdd_Out_2.xxx), _Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2);
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float3 _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxx), _Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2);
            float _Property_0611e1cc5f55410486dca728b061efaf_Out_0 = Vector1_32393eb9d555437685c764966eb12914;
            float3 _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2;
            Unity_Multiply_float(_Multiply_7b3a7f15bcec484586fb2e74b096f6f8_Out_2, (_Property_0611e1cc5f55410486dca728b061efaf_Out_0.xxx), _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2);
            float3 _Add_4ccd19eb971b47898ee413055854734b_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5b1188781a8e4646a60e96a64f62ce8e_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2);
            float3 _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            Unity_Add_float3(_Multiply_5e4a3fd09fb445ed8b3cf235f6a4e178_Out_2, _Add_4ccd19eb971b47898ee413055854734b_Out_2, _Add_e7ff0a40f364460384696f81edcb6c74_Out_2);
            description.Position = _Add_e7ff0a40f364460384696f81edcb6c74_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_59872bf6da214f039950a13dfbf07629_Out_0 = Color_699599e1fb214013afa4e9107c154503;
            float4 _Property_0917a6b752264f8aa324e15bcc5c25c9_Out_0 = Color_24c96a6812594de2a681d3f1a4fe5eb1;
            float _Property_fec185b95fd14a3089086bcaa2d043a1_Out_0 = Vector1_6418af77f3c74440b57f30044ead3d21;
            float _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0 = Vector1_f89360f4e9e349459d6b59af50c17515;
            float4 _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0 = Vector4_88e977257a114610b6ab7b541f4f3601;
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_R_1 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[0];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_G_2 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[1];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_B_3 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[2];
            float _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4 = _Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0[3];
            float3 _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_5e280d8cd41c42db9531a55762dcdc8c_Out_0.xyz), _Split_ccd8b22bd696448b96b7e2b719fb153b_A_4, _RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3);
            float _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0 = Vector1_fb0dafa4b52c44978933c3b768b3824b;
            float _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_93554d97177d4320b3fe1bf3c6f4c688_Out_0, _Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2);
            float2 _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_679c923d1ebb4ebfb3334cf4ad5680fd_Out_2.xx), _TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3);
            float _Property_ea27edd216384780849156789ca3785b_Out_0 = Vector1_b11fb5b9b0d04beb860e34a11359a2a1;
            float _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_04621d4523cb4006a31c70a6a49fcf82_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2);
            float2 _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3);
            float _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_702270d870614aadb45197ced7b9b455_Out_3, _Property_ea27edd216384780849156789ca3785b_Out_0, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2);
            float _Add_5e5d036764b74b81a4298ae7ce526812_Out_2;
            Unity_Add_float(_GradientNoise_807ea8b6a7e3494eaa86999b3dc53d05_Out_2, _GradientNoise_1031a3bc30574ff2a0a080d5d32b2b60_Out_2, _Add_5e5d036764b74b81a4298ae7ce526812_Out_2);
            float _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2;
            Unity_Divide_float(_Add_5e5d036764b74b81a4298ae7ce526812_Out_2, 2, _Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2);
            float _Saturate_b36a9b15cc19479a8274420295850920_Out_1;
            Unity_Saturate_float(_Divide_f4b6acbf17f24fb7ae984acf111f709a_Out_2, _Saturate_b36a9b15cc19479a8274420295850920_Out_1);
            float _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0 = Vector1_314df1cf359b431d86cfe61772b70856;
            float _Power_dca1e65e020d4f3c8302762db680dac2_Out_2;
            Unity_Power_float(_Saturate_b36a9b15cc19479a8274420295850920_Out_1, _Property_763c8a917dfa4e4aacc8c26433eed06c_Out_0, _Power_dca1e65e020d4f3c8302762db680dac2_Out_2);
            float4 _Property_93a6712ff4cd4b42886df0b977a28959_Out_0 = Vector4_5a5ab4f1e88a4f0daa7e1666440b102d;
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[0];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[1];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[2];
            float _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4 = _Property_93a6712ff4cd4b42886df0b977a28959_Out_0[3];
            float4 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4;
            float3 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5;
            float2 _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_R_1, _Split_1bb15c91a1a94108885bfb3859a9e7a2_G_2, 0, 0, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGBA_4, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RGB_5, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6);
            float4 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4;
            float3 _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5;
            float2 _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6;
            Unity_Combine_float(_Split_1bb15c91a1a94108885bfb3859a9e7a2_B_3, _Split_1bb15c91a1a94108885bfb3859a9e7a2_A_4, 0, 0, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGBA_4, _Combine_6e577bcb8e2d4d51bfb7508405263692_RGB_5, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6);
            float _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3;
            Unity_Remap_float(_Power_dca1e65e020d4f3c8302762db680dac2_Out_2, _Combine_5b32cab415bb44eaa2445ac5bae286cc_RG_6, _Combine_6e577bcb8e2d4d51bfb7508405263692_RG_6, _Remap_7253747d288146368a5b4b1fa78f96b9_Out_3);
            float _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1;
            Unity_Absolute_float(_Remap_7253747d288146368a5b4b1fa78f96b9_Out_3, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1);
            float _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3;
            Unity_Smoothstep_float(_Property_fec185b95fd14a3089086bcaa2d043a1_Out_0, _Property_c23491fc433840ea8e40bc7b53e174b1_Out_0, _Absolute_30a7bfd4b2c44b4ab7204a81e8542c7e_Out_1, _Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3);
            float _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0 = Vector1_4c31c067e6da4e8fb0218aa823355d04;
            float _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2f1f1689776f443ebb413cafec2e3beb_Out_0, _Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2);
            float2 _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_98b8b6b05a2245259679c08b791a6329_Out_3.xy), float2 (1, 1), (_Multiply_da49dafc54ae4361b79a258a6168f4ad_Out_2.xx), _TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3);
            float _Property_da9ba4990e684489b61764f42e10694f_Out_0 = Vector1_d2fdeddc5fa944b3895e4372b3981a13;
            float _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_508eb8edd65945f8811ca1ac67f15b3e_Out_3, _Property_da9ba4990e684489b61764f42e10694f_Out_0, _GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2);
            float _Property_401f3e884b5e4e8da229da85df8207c8_Out_0 = Vector1_0b165b42b70147f89838695c6e8f5d02;
            float _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2;
            Unity_Multiply_float(_GradientNoise_350c1a46bde1463a9595adb56ae8fd49_Out_2, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2);
            float _Add_d7e58541f6b74423add2ad46c2c92045_Out_2;
            Unity_Add_float(_Smoothstep_4d5d6a4742d14ea98358386d7a3f1fa2_Out_3, _Multiply_25d5d400feaf411c8324382cbd16b082_Out_2, _Add_d7e58541f6b74423add2ad46c2c92045_Out_2);
            float _Add_bb029142cb5c4380ac780e94589508f2_Out_2;
            Unity_Add_float(1, _Property_401f3e884b5e4e8da229da85df8207c8_Out_0, _Add_bb029142cb5c4380ac780e94589508f2_Out_2);
            float _Divide_3cbe7e805116490784cc260cc348248a_Out_2;
            Unity_Divide_float(_Add_d7e58541f6b74423add2ad46c2c92045_Out_2, _Add_bb029142cb5c4380ac780e94589508f2_Out_2, _Divide_3cbe7e805116490784cc260cc348248a_Out_2);
            float4 _Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3;
            Unity_Lerp_float4(_Property_59872bf6da214f039950a13dfbf07629_Out_0, _Property_0917a6b752264f8aa324e15bcc5c25c9_Out_0, (_Divide_3cbe7e805116490784cc260cc348248a_Out_2.xxxx), _Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3);
            float _Property_7192c99947114867b2a1aeb127be60fc_Out_0 = Vector1_7fa6e24aa65042c98d2a987199357dc6;
            float _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_7192c99947114867b2a1aeb127be60fc_Out_0, _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3);
            float _Multiply_73ac6b7499a74e928109209f27e70133_Out_2;
            Unity_Multiply_float(_Divide_3cbe7e805116490784cc260cc348248a_Out_2, _FresnelEffect_034298648d7c4142a2c8281072d93fc9_Out_3, _Multiply_73ac6b7499a74e928109209f27e70133_Out_2);
            float _Property_d1cf0f3d046341e481f0a08c9fd422b5_Out_0 = Vector1_22df991c6afb4a55850398c5b1908e7f;
            float _Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2;
            Unity_Multiply_float(_Multiply_73ac6b7499a74e928109209f27e70133_Out_2, _Property_d1cf0f3d046341e481f0a08c9fd422b5_Out_0, _Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2);
            float4 _Add_174642f8883047c18dc504356746f29c_Out_2;
            Unity_Add_float4(_Lerp_1af5dbc615764756a834de0b00d6c19b_Out_3, (_Multiply_a56dbc17df164296ba3cfebd2093f28f_Out_2.xxxx), _Add_174642f8883047c18dc504356746f29c_Out_2);
            float _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1);
            float4 _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0 = IN.ScreenPosition;
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_R_1 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[0];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_G_2 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[1];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_B_3 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[2];
            float _Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4 = _ScreenPosition_982ea53ce6f6464faa0d86f18e8effbc_Out_0[3];
            float _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2;
            Unity_Subtract_float(_Split_008cd8833b744f6f98eb8dbd6e0fd4cb_A_4, 1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2);
            float _Subtract_5f6605fd26704b45918c87119d510a96_Out_2;
            Unity_Subtract_float(_SceneDepth_220755ae4f46456b9d42dd4420775d1a_Out_1, _Subtract_81beef3b9a4d463eae94dcd719eab9e1_Out_2, _Subtract_5f6605fd26704b45918c87119d510a96_Out_2);
            float _Property_39706a7e5c994317a1aa961a5a802df6_Out_0 = Vector1_6ddbb35793064667917f9cb6903f211d;
            float _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2;
            Unity_Divide_float(_Subtract_5f6605fd26704b45918c87119d510a96_Out_2, _Property_39706a7e5c994317a1aa961a5a802df6_Out_0, _Divide_60b0005a76d1453f8b759a903b0ce475_Out_2);
            float _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            Unity_Saturate_float(_Divide_60b0005a76d1453f8b759a903b0ce475_Out_2, _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1);
            surface.BaseColor = (_Add_174642f8883047c18dc504356746f29c_Out_2.xyz);
            surface.Alpha = _Saturate_7058b6e3c8ed4f18a25f7395c64dbf78_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "ShaderGraph.PBRMasterGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}