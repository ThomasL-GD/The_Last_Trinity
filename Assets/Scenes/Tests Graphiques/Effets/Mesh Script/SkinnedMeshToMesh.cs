using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class SkinnedMeshToMesh : MonoBehaviour
{
    public SkinnedMeshRenderer m_skinnedMesh;
    public VisualEffect m_VFXGraph;
    public float m_refreshRate;
    
    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(UpdateVFXGraph());
    }

    IEnumerator UpdateVFXGraph()
    {
        while (gameObject.activeSelf)
        {
            Mesh m = new Mesh();
            m_skinnedMesh.BakeMesh(m);
            
            Vector3[] vertices = m.vertices;
            Mesh m2 = new Mesh();
            m2.vertices = vertices;
            
            m_VFXGraph.SetMesh("Mesh", m2);
                
            yield return new WaitForSeconds(m_refreshRate);
        }
    }
}
