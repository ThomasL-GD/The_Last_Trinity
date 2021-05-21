using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Start_Manager : MonoBehaviour
{
    [Header("Waypoints Manager")]
    [SerializeField] [Tooltip("The list of points the guard will travel to, in order from up to down and cycling")] private List<GameObject> m_destinationsTransforms = new List<GameObject>();
    private List<Vector3> m_destinations = new List<Vector3>();
    [SerializeField] [Tooltip("camera principale")] private GameObject m_camera;
    //[SerializeField] [Tooltip("camera principale")] private GameObject m_endview;
    [SerializeField] [Tooltip("vitesse de déplacement de la camera")] [Range(0,10)]private float m_speedCamera = 1.0f;
    [SerializeField] [Tooltip("vitesse de déplacement de la camera")] [Range(0,5)] private float m_speedRotationCamera = 100.0f;
    
    
    // Start is called before the first frame update
    void Start()
    {
        if (m_destinationsTransforms.Count < 2) Debug.LogError("OH NO, U FORGOT TO PUT THE WAYPOINTS FOR THE TRAVELLING OF THE CAMERA !!!");
        if (m_camera == null) Debug.LogError("OH NO, U FORGOT TO ADD A CAMERA FOR THE TRAVELLING OF THE CAMERA !!!");
        
        //Deux points servant de transfère de la caméra
        for (int i = 0; i < m_destinationsTransforms.Count; i++)
        {
            m_destinations.Add(m_destinationsTransforms[i].transform.position);
        }
        
        //La camera se positionne au même emplacement que le premier GameObject de la liste créée au-dessus
        m_camera.transform.position = m_destinationsTransforms[0].transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        //déplacement de la caméra d'un point A à un point B    (les deux points sont dans la liste m_destinationsTransform)
        m_camera.transform.position = Vector3.MoveTowards(m_camera.transform.position,m_destinationsTransforms[1].transform.position, m_speedCamera*Time.deltaTime);
        
        //rotation de la caméra sur la durée pour avoir la même que la rotation finale
        if (m_camera.transform.rotation.x >= m_destinationsTransforms[1].transform.rotation.x)
        {
            m_camera.transform.Rotate(Vector3.left * (m_speedRotationCamera * Time.deltaTime));
        }
        
        
    }
}
