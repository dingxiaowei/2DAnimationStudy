using UnityEngine;
using UnityEditor;
 
public class LuxURPCustomSingleSidedShaderGUI : ShaderGUI
{
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        base.OnGUI(materialEditor, properties);

    	Material material = materialEditor.target as Material;
    	if (material.HasProperty("_Culling")) {
	    	var _Culling = ShaderGUI.FindProperty("_Culling", properties);
			if(_Culling.floatValue == 0.0f) {
				if (material.doubleSidedGI == false) {
					Debug.Log ("Double Sided Global Illumination enabled.");
				}
        		material.doubleSidedGI = true;
        	}
	    }

        //material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
        //material.SetOverrideTag("RenderType", "TransparentCutout");

    //  Needed to make the Selection Outline work
        if (material.HasProperty("_MainTex") && material.HasProperty("_BaseMap") ) {
            if (material.GetTexture("_BaseMap") != null) {
                material.SetTexture("_MainTex", material.GetTexture("_BaseMap"));
            }
        }
    }
}