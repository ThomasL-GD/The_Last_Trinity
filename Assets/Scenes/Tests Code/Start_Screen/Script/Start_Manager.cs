using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class Start_Manager : MonoBehaviour
{
    /*
    [Header("Waypoints Manager")]
    [SerializeField] [Tooltip("The list of points the guard will travel to, in order from up to down and cycling")] private List<GameObject> m_destinationsTransforms = new List<GameObject>();
    private List<Vector3> m_destinations = new List<Vector3>();
    
    [Header("Camera")]
    [SerializeField] [Tooltip("camera principale")] private GameObject m_camera;
    [SerializeField] [Tooltip("vitesse de déplacement de la camera")] [Range(0,10)]private float m_speedCamera = 1.0f;
    [SerializeField] [Tooltip("vitesse de déplacement de la camera")] [Range(0,5)] private float m_speedRotationCamera = 100.0f;
    */

    [Header("Canvas")] 
    [Tooltip("image de Titre")] public Image m_title;
    [SerializeField] [Tooltip("Bouton de démarrage")] private Button m_launchingMenuButton;
    [SerializeField] [Tooltip("Lists des éléments sur lesquels on va se déplacer")] private List<GameObject> m_menuPieces = new List<GameObject>();
    
    [Header("Menu Selector")] 
    [SerializeField] [Tooltip("Selecteur du menu")] private GameObject m_menuSelector;
    
    [Header("Animations")]
    [SerializeField] [Tooltip("temps avant apparition du bouton qui indique d'appuyer sur un bouton")] [Range(0, 1)] private float m_pushAButtonTime = 10.0f;
    [SerializeField] [Tooltip("vitesse d'apparition")] [Range(0, 1)] private float m_opacityDuration = 1.0f;
    private bool m_isFading = true;
    private bool m_menuIsActivate = false;  //indique si le menu est visible ou non
    
    private float m_timer = 0;  //temps qui s'écoule à chaque frame
    
    
    // Start is called before the first frame update
    void Start()
    {
        
        /*
        if (m_destinationsTransforms.Count < 2) Debug.LogError("OH NO, U FORGOT TO PUT THE WAYPOINTS FOR THE TRAVELLING OF THE CAMERA !!!");
        if (m_camera == null) Debug.LogError("OH NO, U FORGOT TO ADD A CAMERA FOR THE TRAVELLING OF THE CAMERA !!!");
        
        //Deux points servant de transfère de la caméra
        for (int i = 0; i < m_destinationsTransforms.Count; i++)
        {
            m_destinations.Add(m_destinationsTransforms[i].transform.position);
        }
        
        //La camera se positionne au même emplacement que le premier GameObject de la liste créée au-dessus
        m_camera.transform.position = m_destinationsTransforms[0].transform.position;
        */

        if (m_title == null) Debug.LogError("OUPS ! U FORGOT TO PUT THE TITLE IMAGE ON THE START MANAGER OBJECT");
        if (m_launchingMenuButton == null) Debug.LogError("OUPS ! U FORGOT TO PUT THE BUTTON TO LAUNCH THE GAME ON THE START MANAGER OBJECT");
        
        m_title.color = new Color(1, 1, 1, 0);

        m_menuSelector.transform.position = m_menuPieces[0].transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        /*
        //déplacement de la caméra d'un point A à un point B    (les deux points sont dans la liste m_destinationsTransform)
        m_camera.transform.position = Vector3.MoveTowards(m_camera.transform.position,m_destinationsTransforms[1].transform.position, m_speedCamera*Time.deltaTime);
        
        //rotation de la caméra sur la durée pour avoir la même que la rotation finale
        if (m_camera.transform.rotation.x >= m_destinationsTransforms[1].transform.rotation.x)
        {
            m_camera.transform.Rotate(Vector3.left * (m_speedRotationCamera * Time.deltaTime));
        }
        else
        {
            m_pushRandomButton.gameObject.SetActive(true);
            bool start = true;

            if (start)
            {
                Debug.Log("Passage à la nouvelle scène");
                //load game scene
                //SceneManager.LoadScene("Intéractions_subpuzzle 1", LoadSceneMode.Additive);
            }
        }
        */

        m_timer++; //récupération du temps qui s'écoule

        if (m_timer >= m_pushAButtonTime)
        {
            m_launchingMenuButton.gameObject.SetActive(true);
        }


        //animation d'opacité
        if (m_isFading)
        {
            //changement d'opacité
            m_title.color += new Color(0, 0, 0, Mathf.Pow(m_opacityDuration, 10.0f));   //le deuxième paramètre de mathf.pow est une puissance de 10
            //Arrêt de fade
            if ( m_title.color.a >= 1) m_isFading = false;
            //Debug.Log($"{m_title.color.a}");
        }

        if (m_menuIsActivate)
        {
            for (int i = 0; i < m_menuPieces.Count; i++)
            {

                if (i <= m_menuPieces.Count && Input.GetKeyDown(KeyCode.UpArrow))
                {
                    Debug.Log("??????????");
                    m_menuSelector.transform.position = m_menuPieces[i - 1].transform.position;

                }
                else if (i >= 0 && Input.GetKeyDown(KeyCode.DownArrow))
                {
                    Debug.Log("??????????");
                    m_menuSelector.transform.position = m_menuPieces[i + 1].transform.position;
                }
            }
            
        }
        
        
    }
    
    
}
