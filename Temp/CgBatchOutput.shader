Shader "Hidden/CC_DoubleVision"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_displace ("Displace", Vector) = (0.7, 0.0, 0.0, 0.0)
		_amount ("Amound", Float) = 1.0
	}

	SubShader
	{
		Pass
		{
			ZTest Always Cull Off ZWrite Off
			Fog { Mode off }
			
			Program "vp" {
// Vertex combos: 1
//   opengl - ALU: 8 to 8
//   d3d9 - ALU: 8 to 8
//   d3d11 - ALU: 2 to 2, TEX: 0 to 0, FLOW: 1 to 1
//   d3d11_9x - ALU: 2 to 2, TEX: 0 to 0, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
"!!ARBvp1.0
# 8 ALU
PARAM c[9] = { { 0 },
		state.matrix.mvp,
		state.matrix.texture[0] };
TEMP R0;
MOV R0.zw, c[0].x;
MOV R0.xy, vertex.texcoord[0];
DP4 result.texcoord[0].y, R0, c[6];
DP4 result.texcoord[0].x, R0, c[5];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 8 instructions, 1 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Matrix 4 [glstate_matrix_texture0]
"vs_2_0
; 8 ALU
def c8, 0.00000000, 0, 0, 0
dcl_position0 v0
dcl_texcoord0 v1
mov r0.zw, c8.x
mov r0.xy, v1
dp4 oT0.y, r0, c5
dp4 oT0.x, r0, c4
dp4 oPos.w, v0, c3
dp4 oPos.z, v0, c2
dp4 oPos.y, v0, c1
dp4 oPos.x, v0, c0
"
}

SubProgram "d3d11 " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
ConstBuffer "UnityPerDraw" 336 // 64 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
ConstBuffer "UnityPerDrawTexMatrices" 768 // 576 used size, 5 vars
Matrix 512 [glstate_matrix_texture0] 4
BindCB "UnityPerDraw" 0
BindCB "UnityPerDrawTexMatrices" 1
// 7 instructions, 1 temp regs, 0 temp arrays:
// ALU 2 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0
eefiecedeedelkdobbmimfefjdhgabnhlefmpcmlabaaaaaaciacaaaaadaaaaaa
cmaaaaaaiaaaaaaaniaaaaaaejfdeheoemaaaaaaacaaaaaaaiaaaaaadiaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaaebaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaadadaaaafaepfdejfeejepeoaafeeffiedepepfceeaaklkl
epfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaaaaaaaaaaabaaaaaaadaaaaaa
aaaaaaaaapaaaaaaeeaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaadamaaaa
fdfgfpfaepfdejfeejepeoaafeeffiedepepfceeaaklklklfdeieefceiabaaaa
eaaaabaafcaaaaaafjaaaaaeegiocaaaaaaaaaaaaeaaaaaafjaaaaaeegiocaaa
abaaaaaaccaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaaddcbabaaaabaaaaaa
ghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaaddccabaaaabaaaaaagiaaaaac
abaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiocaaaaaaaaaaa
abaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaaaaaaaaaaaaaaaaaagbabaaa
aaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaaaaaaaaa
acaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpccabaaaaaaaaaaa
egiocaaaaaaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaaaaaaaaaadiaaaaai
dcaabaaaaaaaaaaafgbfbaaaabaaaaaaegiacaaaabaaaaaacbaaaaaadcaaaaak
dccabaaaabaaaaaaegiacaaaabaaaaaacaaaaaaaagbabaaaabaaaaaaegaabaaa
aaaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;
#define gl_TextureMatrix0 glstate_matrix_texture0
uniform mat4 glstate_matrix_texture0;

varying mediump vec2 xlv_TEXCOORD0;


attribute vec4 _glesMultiTexCoord0;
attribute vec4 _glesVertex;
void main ()
{
  vec2 tmpvar_1;
  tmpvar_1 = _glesMultiTexCoord0.xy;
  mediump vec2 tmpvar_2;
  highp vec2 tmpvar_3;
  highp vec4 tmpvar_4;
  tmpvar_4.zw = vec2(0.0, 0.0);
  tmpvar_4.x = tmpvar_1.x;
  tmpvar_4.y = tmpvar_1.y;
  tmpvar_3 = (gl_TextureMatrix0 * tmpvar_4).xy;
  tmpvar_2 = tmpvar_3;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying mediump vec2 xlv_TEXCOORD0;
uniform mediump float _amount;
uniform lowp vec2 _displace;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tmpvar_1;
  lowp vec4 tmpvar_2;
  tmpvar_2 = texture2D (_MainTex, xlv_TEXCOORD0);
  lowp vec2 tmpvar_3;
  tmpvar_3.x = (_displace.x * 8.0);
  tmpvar_3.y = (_displace.y * 8.0);
  mediump vec2 P_4;
  P_4 = (xlv_TEXCOORD0 + tmpvar_3);
  lowp vec2 tmpvar_5;
  tmpvar_5.x = (_displace.x * 16.0);
  tmpvar_5.y = (_displace.y * 16.0);
  mediump vec2 P_6;
  P_6 = (xlv_TEXCOORD0 + tmpvar_5);
  lowp vec2 tmpvar_7;
  tmpvar_7.x = (_displace.x * 24.0);
  tmpvar_7.y = (_displace.y * 24.0);
  mediump vec2 P_8;
  P_8 = (xlv_TEXCOORD0 + tmpvar_7);
  lowp vec4 tmpvar_9;
  tmpvar_9 = ((((tmpvar_2 + (texture2D (_MainTex, P_4) * 0.5)) + (texture2D (_MainTex, P_6) * 0.3)) + (texture2D (_MainTex, P_8) * 0.2)) * 0.5);
  mediump vec4 tmpvar_10;
  tmpvar_10 = mix (tmpvar_2, tmpvar_9, vec4(_amount));
  tmpvar_1 = tmpvar_10;
  gl_FragData[0] = tmpvar_1;
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
#define gl_TextureMatrix0 glstate_matrix_texture0
uniform mat4 glstate_matrix_texture0;

varying mediump vec2 xlv_TEXCOORD0;


attribute vec4 _glesMultiTexCoord0;
attribute vec4 _glesVertex;
void main ()
{
  vec2 tmpvar_1;
  tmpvar_1 = _glesMultiTexCoord0.xy;
  mediump vec2 tmpvar_2;
  highp vec2 tmpvar_3;
  highp vec4 tmpvar_4;
  tmpvar_4.zw = vec2(0.0, 0.0);
  tmpvar_4.x = tmpvar_1.x;
  tmpvar_4.y = tmpvar_1.y;
  tmpvar_3 = (gl_TextureMatrix0 * tmpvar_4).xy;
  tmpvar_2 = tmpvar_3;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying mediump vec2 xlv_TEXCOORD0;
uniform mediump float _amount;
uniform lowp vec2 _displace;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tmpvar_1;
  lowp vec4 tmpvar_2;
  tmpvar_2 = texture2D (_MainTex, xlv_TEXCOORD0);
  lowp vec2 tmpvar_3;
  tmpvar_3.x = (_displace.x * 8.0);
  tmpvar_3.y = (_displace.y * 8.0);
  mediump vec2 P_4;
  P_4 = (xlv_TEXCOORD0 + tmpvar_3);
  lowp vec2 tmpvar_5;
  tmpvar_5.x = (_displace.x * 16.0);
  tmpvar_5.y = (_displace.y * 16.0);
  mediump vec2 P_6;
  P_6 = (xlv_TEXCOORD0 + tmpvar_5);
  lowp vec2 tmpvar_7;
  tmpvar_7.x = (_displace.x * 24.0);
  tmpvar_7.y = (_displace.y * 24.0);
  mediump vec2 P_8;
  P_8 = (xlv_TEXCOORD0 + tmpvar_7);
  lowp vec4 tmpvar_9;
  tmpvar_9 = ((((tmpvar_2 + (texture2D (_MainTex, P_4) * 0.5)) + (texture2D (_MainTex, P_6) * 0.3)) + (texture2D (_MainTex, P_8) * 0.2)) * 0.5);
  mediump vec4 tmpvar_10;
  tmpvar_10 = mix (tmpvar_2, tmpvar_9, vec4(_amount));
  tmpvar_1 = tmpvar_10;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "flash " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Matrix 4 [glstate_matrix_texture0]
"agal_vs
c8 0.0 0.0 0.0 0.0
[bc]
aaaaaaaaaaaaamacaiaaaaaaabaaaaaaaaaaaaaaaaaaaaaa mov r0.zw, c8.x
aaaaaaaaaaaaadacadaaaaoeaaaaaaaaaaaaaaaaaaaaaaaa mov r0.xy, a3
bdaaaaaaaaaaacaeaaaaaaoeacaaaaaaafaaaaoeabaaaaaa dp4 v0.y, r0, c5
bdaaaaaaaaaaabaeaaaaaaoeacaaaaaaaeaaaaoeabaaaaaa dp4 v0.x, r0, c4
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
Bind "texcoord" TexCoord0
ConstBuffer "UnityPerDraw" 336 // 64 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
ConstBuffer "UnityPerDrawTexMatrices" 768 // 576 used size, 5 vars
Matrix 512 [glstate_matrix_texture0] 4
BindCB "UnityPerDraw" 0
BindCB "UnityPerDrawTexMatrices" 1
// 7 instructions, 1 temp regs, 0 temp arrays:
// ALU 2 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0_level_9_3
eefiecedjgajiifnochboefegodcjikhabpjghhdabaaaaaaceadaaaaaeaaaaaa
daaaaaaaciabaaaahiacaaaammacaaaaebgpgodjpaaaaaaapaaaaaaaaaacpopp
laaaaaaaeaaaaaaaacaaceaaaaaadmaaaaaadmaaaaaaceaaabaadmaaaaaaaaaa
aeaaabaaaaaaaaaaabaacaaaacaaafaaaaaaaaaaaaaaaaaaabacpoppbpaaaaac
afaaaaiaaaaaapjabpaaaaacafaaabiaabaaapjaafaaaaadaaaaadiaabaaffja
agaaoekaaeaaaaaeaaaaadoaafaaoekaabaaaajaaaaaoeiaafaaaaadaaaaapia
aaaaffjaacaaoekaaeaaaaaeaaaaapiaabaaoekaaaaaaajaaaaaoeiaaeaaaaae
aaaaapiaadaaoekaaaaakkjaaaaaoeiaaeaaaaaeaaaaapiaaeaaoekaaaaappja
aaaaoeiaaeaaaaaeaaaaadmaaaaappiaaaaaoekaaaaaoeiaabaaaaacaaaaamma
aaaaoeiappppaaaafdeieefceiabaaaaeaaaabaafcaaaaaafjaaaaaeegiocaaa
aaaaaaaaaeaaaaaafjaaaaaeegiocaaaabaaaaaaccaaaaaafpaaaaadpcbabaaa
aaaaaaaafpaaaaaddcbabaaaabaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaa
gfaaaaaddccabaaaabaaaaaagiaaaaacabaaaaaadiaaaaaipcaabaaaaaaaaaaa
fgbfbaaaaaaaaaaaegiocaaaaaaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaa
egiocaaaaaaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaak
pcaabaaaaaaaaaaaegiocaaaaaaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaa
aaaaaaaadcaaaaakpccabaaaaaaaaaaaegiocaaaaaaaaaaaadaaaaaapgbpbaaa
aaaaaaaaegaobaaaaaaaaaaadiaaaaaidcaabaaaaaaaaaaafgbfbaaaabaaaaaa
egiacaaaabaaaaaacbaaaaaadcaaaaakdccabaaaabaaaaaaegiacaaaabaaaaaa
caaaaaaaagbabaaaabaaaaaaegaabaaaaaaaaaaadoaaaaabejfdeheoemaaaaaa
acaaaaaaaiaaaaaadiaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaa
ebaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaadadaaaafaepfdejfeejepeo
aafeeffiedepepfceeaaklklepfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaaeeaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaadamaaaafdfgfpfaepfdejfeejepeoaafeeffiedepepfcee
aaklklkl"
}

}
Program "fp" {
// Fragment combos: 1
//   opengl - ALU: 20 to 20, TEX: 4 to 4
//   d3d9 - ALU: 18 to 18, TEX: 4 to 4
//   d3d11 - ALU: 0 to 0, TEX: 4 to 4, FLOW: 1 to 1
//   d3d11_9x - ALU: 0 to 0, TEX: 4 to 4, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { }
Vector 0 [_displace]
Float 1 [_amount]
SetTexture 0 [_MainTex] 2D
"!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 20 ALU, 4 TEX
PARAM c[4] = { program.local[0..1],
		{ 8, 0.5, 16, 0.30000001 },
		{ 24, 0.2 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MOV R0.zw, c[2].xyxz;
MUL R0.xy, R0.z, c[0];
MOV R0.z, c[3].x;
MUL R1.xy, R0.z, c[0];
ADD R1.xy, fragment.texcoord[0], R1;
MUL R0.zw, R0.w, c[0].xyxy;
ADD R0.zw, fragment.texcoord[0].xyxy, R0;
ADD R0.xy, fragment.texcoord[0], R0;
TEX R3, R1, texture[0], 2D;
TEX R2, R0.zwzw, texture[0], 2D;
TEX R1, R0, texture[0], 2D;
TEX R0, fragment.texcoord[0], texture[0], 2D;
MUL R1, R1, c[2].y;
ADD R1, R0, R1;
MUL R2, R2, c[2].w;
MUL R3, R3, c[3].y;
ADD R1, R1, R2;
ADD R1, R1, R3;
MAD R1, R1, c[2].y, -R0;
MAD result.color, R1, c[1].x, R0;
END
# 20 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Vector 0 [_displace]
Float 1 [_amount]
SetTexture 0 [_MainTex] 2D
"ps_2_0
; 18 ALU, 4 TEX
dcl_2d s0
def c2, 8.00000000, 0.50000000, 16.00000000, 0.30000001
def c3, 24.00000000, 0.20000000, 0, 0
dcl t0.xy
texld r3, t0, s0
mov_pp r0.xy, c0
mul_pp r0.xy, c2.x, r0
add_pp r2.xy, t0, r0
mov_pp r0.xy, c0
mov_pp r1.xy, c0
mul_pp r0.xy, c3.x, r0
mul_pp r1.xy, c2.z, r1
add_pp r0.xy, t0, r0
add_pp r1.xy, t0, r1
texld r0, r0, s0
texld r1, r1, s0
texld r2, r2, s0
mul r2, r2, c2.y
add_pp r2, r3, r2
mul r1, r1, c2.w
mul r0, r0, c3.y
add_pp r1, r2, r1
add_pp r0, r1, r0
mad_pp r0, r0, c2.y, -r3
mad_pp r0, r0, c1.x, r3
mov_pp oC0, r0
"
}

SubProgram "d3d11 " {
Keywords { }
ConstBuffer "$Globals" 32 // 28 used size, 3 vars
Vector 16 [_displace] 2
Float 24 [_amount]
BindCB "$Globals" 0
SetTexture 0 [_MainTex] 2D 0
// 12 instructions, 4 temp regs, 0 temp arrays:
// ALU 0 float, 0 int, 0 uint
// TEX 4 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0
eefiecedoecenlbpglgpmlkbnngokdhidoclfiipabaaaaaapmacaaaaadaaaaaa
cmaaaaaaieaaaaaaliaaaaaaejfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaaeeaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaadadaaaafdfgfpfaepfdejfeejepeoaafeeffiedepepfcee
aaklklklepfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklklfdeieefcdmacaaaa
eaaaaaaaipaaaaaafjaaaaaeegiocaaaaaaaaaaaacaaaaaafkaaaaadaagabaaa
aaaaaaaafibiaaaeaahabaaaaaaaaaaaffffaaaagcbaaaaddcbabaaaabaaaaaa
gfaaaaadpccabaaaaaaaaaaagiaaaaacaeaaaaaadcaaaaandcaabaaaaaaaaaaa
egiacaaaaaaaaaaaabaaaaaaaceaaaaaaaaamaebaaaamaebaaaaaaaaaaaaaaaa
egbabaaaabaaaaaaefaaaaajpcaabaaaaaaaaaaaegaabaaaaaaaaaaaeghobaaa
aaaaaaaaaagabaaaaaaaaaaadcaaaaanpcaabaaaabaaaaaaegiecaaaaaaaaaaa
abaaaaaaaceaaaaaaaaaaaebaaaaaaebaaaaiaebaaaaiaebegbebaaaabaaaaaa
efaaaaajpcaabaaaacaaaaaaogakbaaaabaaaaaaeghobaaaaaaaaaaaaagabaaa
aaaaaaaaefaaaaajpcaabaaaabaaaaaaegaabaaaabaaaaaaeghobaaaaaaaaaaa
aagabaaaaaaaaaaaefaaaaajpcaabaaaadaaaaaaegbabaaaabaaaaaaeghobaaa
aaaaaaaaaagabaaaaaaaaaaadcaaaaampcaabaaaabaaaaaaegaobaaaabaaaaaa
aceaaaaaaaaaaadpaaaaaadpaaaaaadpaaaaaadpegaobaaaadaaaaaadcaaaaam
pcaabaaaabaaaaaaegaobaaaacaaaaaaaceaaaaajkjjjjdojkjjjjdojkjjjjdo
jkjjjjdoegaobaaaabaaaaaadcaaaaampcaabaaaaaaaaaaaegaobaaaaaaaaaaa
aceaaaaamnmmemdomnmmemdomnmmemdomnmmemdoegaobaaaabaaaaaadcaaaaan
pcaabaaaaaaaaaaaegaobaaaaaaaaaaaaceaaaaaaaaaaadpaaaaaadpaaaaaadp
aaaaaadpegaobaiaebaaaaaaadaaaaaadcaaaaakpccabaaaaaaaaaaakgikcaaa
aaaaaaaaabaaaaaaegaobaaaaaaaaaaaegaobaaaadaaaaaadoaaaaab"
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
Vector 0 [_displace]
Float 1 [_amount]
SetTexture 0 [_MainTex] 2D
"agal_ps
c2 8.0 0.5 16.0 0.3
c3 24.0 0.2 0.0 0.0
[bc]
ciaaaaaaadaaapacaaaaaaoeaeaaaaaaaaaaaaaaafaababb tex r3, v0, s0 <2d wrap linear point>
aaaaaaaaaaaaadacaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r0.xy, c0
adaaaaaaaaaaadacacaaaaaaabaaaaaaaaaaaafeacaaaaaa mul r0.xy, c2.x, r0.xyyy
abaaaaaaacaaadacaaaaaaoeaeaaaaaaaaaaaafeacaaaaaa add r2.xy, v0, r0.xyyy
aaaaaaaaaaaaadacaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r0.xy, c0
aaaaaaaaabaaadacaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r1.xy, c0
adaaaaaaaaaaadacadaaaaaaabaaaaaaaaaaaafeacaaaaaa mul r0.xy, c3.x, r0.xyyy
adaaaaaaabaaadacacaaaakkabaaaaaaabaaaafeacaaaaaa mul r1.xy, c2.z, r1.xyyy
abaaaaaaaaaaadacaaaaaaoeaeaaaaaaaaaaaafeacaaaaaa add r0.xy, v0, r0.xyyy
abaaaaaaabaaadacaaaaaaoeaeaaaaaaabaaaafeacaaaaaa add r1.xy, v0, r1.xyyy
ciaaaaaaaaaaapacaaaaaafeacaaaaaaaaaaaaaaafaababb tex r0, r0.xyyy, s0 <2d wrap linear point>
ciaaaaaaabaaapacabaaaafeacaaaaaaaaaaaaaaafaababb tex r1, r1.xyyy, s0 <2d wrap linear point>
ciaaaaaaacaaapacacaaaafeacaaaaaaaaaaaaaaafaababb tex r2, r2.xyyy, s0 <2d wrap linear point>
adaaaaaaacaaapacacaaaaoeacaaaaaaacaaaaffabaaaaaa mul r2, r2, c2.y
abaaaaaaacaaapacadaaaaoeacaaaaaaacaaaaoeacaaaaaa add r2, r3, r2
adaaaaaaabaaapacabaaaaoeacaaaaaaacaaaappabaaaaaa mul r1, r1, c2.w
adaaaaaaaaaaapacaaaaaaoeacaaaaaaadaaaaffabaaaaaa mul r0, r0, c3.y
abaaaaaaabaaapacacaaaaoeacaaaaaaabaaaaoeacaaaaaa add r1, r2, r1
abaaaaaaaaaaapacabaaaaoeacaaaaaaaaaaaaoeacaaaaaa add r0, r1, r0
adaaaaaaabaaapacaaaaaaoeacaaaaaaacaaaaffabaaaaaa mul r1, r0, c2.y
acaaaaaaaaaaapacabaaaaoeacaaaaaaadaaaaoeacaaaaaa sub r0, r1, r3
adaaaaaaaaaaapacaaaaaaoeacaaaaaaabaaaaaaabaaaaaa mul r0, r0, c1.x
abaaaaaaaaaaapacaaaaaaoeacaaaaaaadaaaaoeacaaaaaa add r0, r0, r3
aaaaaaaaaaaaapadaaaaaaoeacaaaaaaaaaaaaaaaaaaaaaa mov o0, r0
"
}

SubProgram "d3d11_9x " {
Keywords { }
ConstBuffer "$Globals" 32 // 28 used size, 3 vars
Vector 16 [_displace] 2
Float 24 [_amount]
BindCB "$Globals" 0
SetTexture 0 [_MainTex] 2D 0
// 12 instructions, 4 temp regs, 0 temp arrays:
// ALU 0 float, 0 int, 0 uint
// TEX 4 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0_level_9_3
eefiecedeeaocjbnnlcjlmdblafefaknlgjcgbifabaaaaaaieaeaaaaaeaaaaaa
daaaaaaaleabaaaapiadaaaafaaeaaaaebgpgodjhmabaaaahmabaaaaaaacpppp
eiabaaaadeaaaaaaabaaciaaaaaadeaaaaaadeaaabaaceaaaaaadeaaaaaaaaaa
aaaaabaaabaaaaaaaaaaaaaaabacppppfbaaaaafabaaapkaaaaaaaebaaaaaadp
aaaaiaebjkjjjjdofbaaaaafacaaapkaaaaamaebmnmmemdoaaaaaaaaaaaaaaaa
bpaaaaacaaaaaaiaaaaacdlabpaaaaacaaaaaajaaaaiapkaabaaaaacaaaaadia
aaaaoekaaeaaaaaeabaacdiaaaaaoeiaacaaaakaaaaaoelaaeaaaaaeacaacdia
aaaaoeiaabaakkkaaaaaoelaecaaaaadabaaapiaabaaoeiaaaaioekaecaaaaad
acaaapiaacaaoeiaaaaioekaaeaaaaaeaaaacdiaaaaaoeiaabaaaakaaaaaoela
ecaaaaadadaacpiaaaaaoelaaaaioekaecaaaaadaaaaapiaaaaaoeiaaaaioeka
aeaaaaaeaaaacpiaaaaaoeiaabaaffkaadaaoeiaaeaaaaaeaaaacpiaacaaoeia
abaappkaaaaaoeiaaeaaaaaeaaaacpiaabaaoeiaacaaffkaaaaaoeiaaeaaaaae
aaaacpiaaaaaoeiaabaaffkaadaaoeibaeaaaaaeaaaacpiaaaaakkkaaaaaoeia
adaaoeiaabaaaaacaaaicpiaaaaaoeiappppaaaafdeieefcdmacaaaaeaaaaaaa
ipaaaaaafjaaaaaeegiocaaaaaaaaaaaacaaaaaafkaaaaadaagabaaaaaaaaaaa
fibiaaaeaahabaaaaaaaaaaaffffaaaagcbaaaaddcbabaaaabaaaaaagfaaaaad
pccabaaaaaaaaaaagiaaaaacaeaaaaaadcaaaaandcaabaaaaaaaaaaaegiacaaa
aaaaaaaaabaaaaaaaceaaaaaaaaamaebaaaamaebaaaaaaaaaaaaaaaaegbabaaa
abaaaaaaefaaaaajpcaabaaaaaaaaaaaegaabaaaaaaaaaaaeghobaaaaaaaaaaa
aagabaaaaaaaaaaadcaaaaanpcaabaaaabaaaaaaegiecaaaaaaaaaaaabaaaaaa
aceaaaaaaaaaaaebaaaaaaebaaaaiaebaaaaiaebegbebaaaabaaaaaaefaaaaaj
pcaabaaaacaaaaaaogakbaaaabaaaaaaeghobaaaaaaaaaaaaagabaaaaaaaaaaa
efaaaaajpcaabaaaabaaaaaaegaabaaaabaaaaaaeghobaaaaaaaaaaaaagabaaa
aaaaaaaaefaaaaajpcaabaaaadaaaaaaegbabaaaabaaaaaaeghobaaaaaaaaaaa
aagabaaaaaaaaaaadcaaaaampcaabaaaabaaaaaaegaobaaaabaaaaaaaceaaaaa
aaaaaadpaaaaaadpaaaaaadpaaaaaadpegaobaaaadaaaaaadcaaaaampcaabaaa
abaaaaaaegaobaaaacaaaaaaaceaaaaajkjjjjdojkjjjjdojkjjjjdojkjjjjdo
egaobaaaabaaaaaadcaaaaampcaabaaaaaaaaaaaegaobaaaaaaaaaaaaceaaaaa
mnmmemdomnmmemdomnmmemdomnmmemdoegaobaaaabaaaaaadcaaaaanpcaabaaa
aaaaaaaaegaobaaaaaaaaaaaaceaaaaaaaaaaadpaaaaaadpaaaaaadpaaaaaadp
egaobaiaebaaaaaaadaaaaaadcaaaaakpccabaaaaaaaaaaakgikcaaaaaaaaaaa
abaaaaaaegaobaaaaaaaaaaaegaobaaaadaaaaaadoaaaaabejfdeheofaaaaaaa
acaaaaaaaiaaaaaadiaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaa
eeaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaadadaaaafdfgfpfaepfdejfe
ejepeoaafeeffiedepepfceeaaklklklepfdeheocmaaaaaaabaaaaaaaiaaaaaa
caaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgf
heaaklkl"
}

}

#LINE 42

		}
	}

	FallBack off
}
