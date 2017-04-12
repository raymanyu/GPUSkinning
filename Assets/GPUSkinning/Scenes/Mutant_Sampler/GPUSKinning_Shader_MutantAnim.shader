Shader "GPUSkinning/GPUSkinning_Unlit_MutantAnim"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	#include "Assets/GPUSkinning/Resources/GPUSkinningInclude.cginc"

	uniform float4x4 _GPUSkinning_MatrixArray[26];

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		float4 uv2 : TEXCOORD1;
		float4 uv3 : TEXCOORD2;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	v2f vert(appdata v)
	{
		v2f o;

#ifdef GPU_SKINNING_MATRIX_ARRAY
		float4x4 mat0 = _GPUSkinning_MatrixArray[v.uv2.x];
		float4x4 mat1 = _GPUSkinning_MatrixArray[v.uv2.z];
		float4x4 mat2 = _GPUSkinning_MatrixArray[v.uv3.x];
		float4x4 mat3 = _GPUSkinning_MatrixArray[v.uv3.z];
#endif

#ifdef GPU_SKINNING_TEXTURE_MATRIX
		int frameStartIndex = getFrameStartIndex();
		float4x4 mat0 = getMatrix(frameStartIndex, v.uv2.x);
		float4x4 mat1 = getMatrix(frameStartIndex, v.uv2.z);
		float4x4 mat2 = getMatrix(frameStartIndex, v.uv3.x);
		float4x4 mat3 = getMatrix(frameStartIndex, v.uv3.z);
#endif

		

		
		float4 pos =
			mul(mat0, v.vertex) * v.uv2.y +
			mul(mat1, v.vertex) * v.uv2.w;
		

		

		o.vertex = UnityObjectToClipPos(pos);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.uv);
		return col;
	}
	ENDCG

	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile GPU_SKINNING_MATRIX_ARRAY GPU_SKINNING_TEXTURE_MATRIX
			ENDCG
		}
	}
}
