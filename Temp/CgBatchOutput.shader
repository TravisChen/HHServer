// unlit, vertex colour, premultiplied alpha blend

Shader "tk2d/PremulVertexColor" 
{
	Properties 
	{
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	}

	SubShader
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		ZWrite Off Lighting Off Cull Off Fog { Mode Off } Blend One OneMinusSrcAlpha
		LOD 110
		
		Pass 
		{
			Program "vp" {
// Vertex combos: 1
//   opengl - ALU: 6 to 6
//   d3d9 - ALU: 6 to 6
//   d3d11 - ALU: 1 to 1, TEX: 0 to 0, FLOW: 1 to 1
//   d3d11_9x - ALU: 1 to 1, TEX: 0 to 0, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
"!!ARBvp1.0
# 6 ALU
PARAM c[5] = { program.local[0],
		state.matrix.mvp };
MOV result.color, vertex.color;
MOV result.texcoord[0].xy, vertex.texcoord[0];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 6 instructions, 0 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
"vs_2_0
; 6 ALU
dcl_position0 v0
dcl_color0 v1
dcl_texcoord0 v2
mov oD0, v1
mov oT0.xy, v2
dp4 oPos.w, v0, c3
dp4 oPos.z, v0, c2
dp4 oPos.y, v0, c1
dp4 oPos.x, v0, c0
"
}

SubProgram "d3d11 " {
Keywords { }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
ConstBuffer "UnityPerDraw" 336 // 64 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
BindCB "UnityPerDraw" 0
// 7 instructions, 1 temp regs, 0 temp arrays:
// ALU 1 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0
eefiecedgkjagpdphghibkdkhcjmdlcpdknikoifabaaaaaaeiacaaaaadaaaaaa
cmaaaaaajmaaaaaabaabaaaaejfdeheogiaaaaaaadaaaaaaaiaaaaaafaaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaafjaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaafpaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
adadaaaafaepfdejfeejepeoaaedepemepfcaafeeffiedepepfceeaaepfdeheo
gmaaaaaaadaaaaaaaiaaaaaafaaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaa
apaaaaaafmaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapaaaaaagcaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaacaaaaaaadamaaaafdfgfpfagphdgjhegjgpgoaa
edepemepfcaafeeffiedepepfceeaaklfdeieefcdaabaaaaeaaaabaaemaaaaaa
fjaaaaaeegiocaaaaaaaaaaaaeaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaad
pcbabaaaabaaaaaafpaaaaaddcbabaaaacaaaaaaghaaaaaepccabaaaaaaaaaaa
abaaaaaagfaaaaadpccabaaaabaaaaaagfaaaaaddccabaaaacaaaaaagiaaaaac
abaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiocaaaaaaaaaaa
abaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaaaaaaaaaaaaaaaaaagbabaaa
aaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaaaaaaaaa
acaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpccabaaaaaaaaaaa
egiocaaaaaaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaaaaaaaaaadgaaaaaf
pccabaaaabaaaaaaegbobaaaabaaaaaadgaaaaafdccabaaaacaaaaaaegbabaaa
acaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD0;
varying lowp vec4 xlv_COLOR;

attribute vec4 _glesMultiTexCoord0;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_COLOR = _glesColor;
  xlv_TEXCOORD0 = _glesMultiTexCoord0.xy;
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD0;
varying lowp vec4 xlv_COLOR;
uniform sampler2D _MainTex;
void main ()
{
  gl_FragData[0] = (texture2D (_MainTex, xlv_TEXCOORD0) * xlv_COLOR);
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD0;
varying lowp vec4 xlv_COLOR;

attribute vec4 _glesMultiTexCoord0;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_COLOR = _glesColor;
  xlv_TEXCOORD0 = _glesMultiTexCoord0.xy;
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD0;
varying lowp vec4 xlv_COLOR;
uniform sampler2D _MainTex;
void main ()
{
  gl_FragData[0] = (texture2D (_MainTex, xlv_TEXCOORD0) * xlv_COLOR);
}



#endif"
}

SubProgram "flash " {
Keywords { }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
"agal_vs
[bc]
aaaaaaaaahaaapaeacaaaaoeaaaaaaaaaaaaaaaaaaaaaaaa mov v7, a2
aaaaaaaaaaaaadaeadaaaaoeaaaaaaaaaaaaaaaaaaaaaaaa mov v0.xy, a3
bdaaaaaaaaaaaiadaaaaaaoeaaaaaaaaadaaaaoeabaaaaaa dp4 o0.w, a0, c3
bdaaaaaaaaaaaeadaaaaaaoeaaaaaaaaacaaaaoeabaaaaaa dp4 o0.z, a0, c2
bdaaaaaaaaaaacadaaaaaaoeaaaaaaaaabaaaaoeabaaaaaa dp4 o0.y, a0, c1
bdaaaaaaaaaaabadaaaaaaoeaaaaaaaaaaaaaaoeabaaaaaa dp4 o0.x, a0, c0
aaaaaaaaaaaaamaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v0.zw, c0
"
}

SubProgram "d3d11_9x " {
Keywords { }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
ConstBuffer "UnityPerDraw" 336 // 64 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
BindCB "UnityPerDraw" 0
// 7 instructions, 1 temp regs, 0 temp arrays:
// ALU 1 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0_level_9_3
eefiecedmafogaieelelnlbandcbfiahfenifihdabaaaaaadiadaaaaaeaaaaaa
daaaaaaabmabaaaafeacaaaameacaaaaebgpgodjoeaaaaaaoeaaaaaaaaacpopp
laaaaaaadeaaaaaaabaaceaaaaaadaaaaaaadaaaaaaaceaaabaadaaaaaaaaaaa
aeaaabaaaaaaaaaaaaaaaaaaabacpoppbpaaaaacafaaaaiaaaaaapjabpaaaaac
afaaabiaabaaapjabpaaaaacafaaaciaacaaapjaafaaaaadaaaaapiaaaaaffja
acaaoekaaeaaaaaeaaaaapiaabaaoekaaaaaaajaaaaaoeiaaeaaaaaeaaaaapia
adaaoekaaaaakkjaaaaaoeiaaeaaaaaeaaaaapiaaeaaoekaaaaappjaaaaaoeia
aeaaaaaeaaaaadmaaaaappiaaaaaoekaaaaaoeiaabaaaaacaaaaammaaaaaoeia
abaaaaacaaaaapoaabaaoejaabaaaaacabaaadoaacaaoejappppaaaafdeieefc
daabaaaaeaaaabaaemaaaaaafjaaaaaeegiocaaaaaaaaaaaaeaaaaaafpaaaaad
pcbabaaaaaaaaaaafpaaaaadpcbabaaaabaaaaaafpaaaaaddcbabaaaacaaaaaa
ghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaadpccabaaaabaaaaaagfaaaaad
dccabaaaacaaaaaagiaaaaacabaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaa
aaaaaaaaegiocaaaaaaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaa
aaaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaa
aaaaaaaaegiocaaaaaaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaa
dcaaaaakpccabaaaaaaaaaaaegiocaaaaaaaaaaaadaaaaaapgbpbaaaaaaaaaaa
egaobaaaaaaaaaaadgaaaaafpccabaaaabaaaaaaegbobaaaabaaaaaadgaaaaaf
dccabaaaacaaaaaaegbabaaaacaaaaaadoaaaaabejfdeheogiaaaaaaadaaaaaa
aiaaaaaafaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaafjaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapapaaaafpaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaacaaaaaaadadaaaafaepfdejfeejepeoaaedepemepfcaafeeffiedep
epfceeaaepfdeheogmaaaaaaadaaaaaaaiaaaaaafaaaaaaaaaaaaaaaabaaaaaa
adaaaaaaaaaaaaaaapaaaaaafmaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaa
apaaaaaagcaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaaadamaaaafdfgfpfa
gphdgjhegjgpgoaaedepemepfcaafeeffiedepepfceeaakl"
}

}
Program "fp" {
// Fragment combos: 1
//   opengl - ALU: 2 to 2, TEX: 1 to 1
//   d3d9 - ALU: 2 to 2, TEX: 1 to 1
//   d3d11 - ALU: 1 to 1, TEX: 1 to 1, FLOW: 1 to 1
//   d3d11_9x - ALU: 1 to 1, TEX: 1 to 1, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { }
SetTexture 0 [_MainTex] 2D
"!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 2 ALU, 1 TEX
TEMP R0;
TEX R0, fragment.texcoord[0], texture[0], 2D;
MUL result.color, R0, fragment.color.primary;
END
# 2 instructions, 1 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
SetTexture 0 [_MainTex] 2D
"ps_2_0
; 2 ALU, 1 TEX
dcl_2d s0
dcl v0
dcl t0.xy
texld r0, t0, s0
mul r0, r0, v0
mov_pp oC0, r0
"
}

SubProgram "d3d11 " {
Keywords { }
SetTexture 0 [_MainTex] 2D 0
// 3 instructions, 1 temp regs, 0 temp arrays:
// ALU 1 float, 0 int, 0 uint
// TEX 1 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0
eefiecedfeekenokghlgjhcgjbmilcaaepbfkhjcabaaaaaahaabaaaaadaaaaaa
cmaaaaaakaaaaaaaneaaaaaaejfdeheogmaaaaaaadaaaaaaaiaaaaaafaaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaafmaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaagcaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
adadaaaafdfgfpfagphdgjhegjgpgoaaedepemepfcaafeeffiedepepfceeaakl
epfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
aaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklklfdeieefcjeaaaaaaeaaaaaaa
cfaaaaaafkaaaaadaagabaaaaaaaaaaafibiaaaeaahabaaaaaaaaaaaffffaaaa
gcbaaaadpcbabaaaabaaaaaagcbaaaaddcbabaaaacaaaaaagfaaaaadpccabaaa
aaaaaaaagiaaaaacabaaaaaaefaaaaajpcaabaaaaaaaaaaaegbabaaaacaaaaaa
eghobaaaaaaaaaaaaagabaaaaaaaaaaadiaaaaahpccabaaaaaaaaaaaegaobaaa
aaaaaaaaegbobaaaabaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES"
}

SubProgram "flash " {
Keywords { }
SetTexture 0 [_MainTex] 2D
"agal_ps
[bc]
ciaaaaaaaaaaapacaaaaaaoeaeaaaaaaaaaaaaaaafaababb tex r0, v0, s0 <2d wrap linear point>
adaaaaaaaaaaapacaaaaaaoeacaaaaaaahaaaaoeaeaaaaaa mul r0, r0, v7
aaaaaaaaaaaaapadaaaaaaoeacaaaaaaaaaaaaaaaaaaaaaa mov o0, r0
"
}

SubProgram "d3d11_9x " {
Keywords { }
SetTexture 0 [_MainTex] 2D 0
// 3 instructions, 1 temp regs, 0 temp arrays:
// ALU 1 float, 0 int, 0 uint
// TEX 1 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0_level_9_3
eefiecedlhclbjklebdocgfnocopidlhbelhibbhabaaaaaapmabaaaaaeaaaaaa
daaaaaaaliaaaaaafeabaaaamiabaaaaebgpgodjiaaaaaaaiaaaaaaaaaacpppp
fiaaaaaaciaaaaaaaaaaciaaaaaaciaaaaaaciaaabaaceaaaaaaciaaaaaaaaaa
abacppppbpaaaaacaaaaaaiaaaaaaplabpaaaaacaaaaaaiaabaaadlabpaaaaac
aaaaaajaaaaiapkaecaaaaadaaaaapiaabaaoelaaaaioekaafaaaaadaaaacpia
aaaaoeiaaaaaoelaabaaaaacaaaicpiaaaaaoeiappppaaaafdeieefcjeaaaaaa
eaaaaaaacfaaaaaafkaaaaadaagabaaaaaaaaaaafibiaaaeaahabaaaaaaaaaaa
ffffaaaagcbaaaadpcbabaaaabaaaaaagcbaaaaddcbabaaaacaaaaaagfaaaaad
pccabaaaaaaaaaaagiaaaaacabaaaaaaefaaaaajpcaabaaaaaaaaaaaegbabaaa
acaaaaaaeghobaaaaaaaaaaaaagabaaaaaaaaaaadiaaaaahpccabaaaaaaaaaaa
egaobaaaaaaaaaaaegbobaaaabaaaaaadoaaaaabejfdeheogmaaaaaaadaaaaaa
aiaaaaaafaaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaafmaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapapaaaagcaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaacaaaaaaadadaaaafdfgfpfagphdgjhegjgpgoaaedepemepfcaafeef
fiedepepfceeaaklepfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklkl"
}

}

#LINE 56

		} 
	}

	SubShader 
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		ZWrite Off Blend One OneMinusSrcAlpha Cull Off Fog { Mode Off } 
		LOD 100
		
		BindChannels 
		{
			Bind "Vertex", vertex
			Bind "TexCoord", texcoord
			Bind "Color", color
		}

		Pass 
		{
			Lighting Off
			SetTexture [_MainTex] { combine texture * primary } 
		}
	}
}
