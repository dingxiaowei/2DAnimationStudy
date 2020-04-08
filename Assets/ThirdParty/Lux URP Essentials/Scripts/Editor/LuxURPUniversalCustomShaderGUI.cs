using UnityEngine;
using UnityEditor;
 
public class LuxURPUniversalCustomShaderGUI : ShaderGUI
{
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        base.OnGUI(materialEditor, properties);

    	Material material = materialEditor.target as Material;

    //  Double sided
        if (material.HasProperty("_Cull")) {
            var _Culling = ShaderGUI.FindProperty("_Cull", properties);
            if(_Culling.floatValue == 0.0f) {
                if (material.doubleSidedGI == false) {
                    Debug.Log ("Material " + material.name + ": Double Sided Global Illumination enabled.", (Object)material);
                }
                material.doubleSidedGI = true;
            }
            else {
                if (material.doubleSidedGI == true) {
                    Debug.Log ("Material " + material.name + ": Double Sided Global Illumination disabled.", (Object)material);
                }
                material.doubleSidedGI = false;
            }
        }

    //  Emission
        if ( material.HasProperty("_Emission")) {
    		if ( material.GetFloat("_Emission") == 1.0f) {
    			material.globalIlluminationFlags = MaterialGlobalIlluminationFlags.BakedEmissive;
    		}
    		else {
    			material.globalIlluminationFlags = MaterialGlobalIlluminationFlags.BakedEmissive;
    			material.globalIlluminationFlags |= MaterialGlobalIlluminationFlags.EmissiveIsBlack;
    		}
        }

    //  Get RenderQueue Offset - if any
        int QueueOffset = 0;
        if ( material.HasProperty("_QueueOffset") ) {
            QueueOffset = material.GetInt("_QueueOffset");
        }

    //  Alpha Testing
        bool enableAlphaTesting = false;
    //  Check old custom property
        if ( material.HasProperty("_EnableAlphaTesting")) {
            if ( material.GetFloat("_EnableAlphaTesting") == 1.0f ) {
                if( material.HasProperty("_AlphaFromMaskMap") && material.HasProperty("_MaskMap") ) {
                    if (material.GetFloat("_AlphaFromMaskMap") == 1.0f && material.GetFloat("_EnableMaskMap") == 1.0f) {
                        enableAlphaTesting = true;
                    }
                }
                else {
                    enableAlphaTesting = true;
                }
            }

            if(enableAlphaTesting) {
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest + QueueOffset;
                material.SetOverrideTag("RenderType", "TransparentCutout");
            }
            else {
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Geometry + QueueOffset;
                material.SetOverrideTag("RenderType", "Opaque");
            }
        }
    //  We also check for the "standard" property
        if ( material.HasProperty("_AlphaClip")) {
            if ( material.GetFloat("_AlphaClip") == 1.0f ) {
                if( material.HasProperty("_AlphaFromMaskMap") && material.HasProperty("_MaskMap") ) {
                    if (material.GetFloat("_AlphaFromMaskMap") == 1.0f && material.GetFloat("_EnableMaskMap") == 1.0f) {
                        enableAlphaTesting = true;
                    }
                }
                else {
                    enableAlphaTesting = true;
                }
            }
            if(enableAlphaTesting) {
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest + QueueOffset;
                material.SetOverrideTag("RenderType", "TransparentCutout");
            }
            else {
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Geometry + QueueOffset;
                material.SetOverrideTag("RenderType", "Opaque");
            }
        }

    //  Get rid of the normal map issue
        if ( material.HasProperty("_BumpMap") ) {
            if (material.HasProperty("_ApplyNormal") ) {
                if ( material.GetFloat("_ApplyNormal") == 0.0f && material.GetTexture("_BumpMap") == null ) {
                    //material.SetTexture("_BumpMap", Texture2D.normalTexture); // Is not linear?!
                    material.SetTexture("_BumpMap", Resources.Load("LuxURPdefaultBump") as Texture2D );
                }
            }
        }


	//  Needed to make the Selection Outline work
        if (material.HasProperty("_MainTex") && material.HasProperty("_BaseMap") ) {

        //  Alpha might be stored in the Mask Map
            bool copyMaskMap = false;
            if(material.HasProperty("_AlphaFromMaskMap") && material.HasProperty("_MaskMap")) {
                if (material.GetFloat("_AlphaFromMaskMap") == 1.0) {
                    copyMaskMap = true;
                }
            }
            if (copyMaskMap) {
                if (material.GetTexture("_MaskMap") != null) {
                    material.SetTexture("_MainTex", material.GetTexture("_MaskMap"));
                } 
            }
            else {
                if (material.GetTexture("_BaseMap") != null) {
                    material.SetTexture("_MainTex", material.GetTexture("_BaseMap"));
                }
            }
        }
    }
}