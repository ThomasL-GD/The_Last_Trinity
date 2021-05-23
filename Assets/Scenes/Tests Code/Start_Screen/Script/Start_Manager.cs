using System.Collections.Generic;
using TMPro;
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
    [SerializeField] [Tooltip("Bouton de démarrage")] private Button m_pressStartButton;
    [SerializeField] [Tooltip("texte de démarrage")] private TextMeshProUGUI m_pressStartText;
    [SerializeField] [Tooltip("Menu Principal")] private GameObject m_mainMenu;
    [SerializeField] [Tooltip("Liste des positions sur lesquelles on va se déplacer ")] private GameObject[] m_menuPiecesButton;
    //[SerializeField] [Tooltip("Liste des éléments sur lesquelles on va se déplacer")] private List<GameObject> m_menuPieces = new List<GameObject>();

    [Header("Menu Selector")] 
    [SerializeField] [Tooltip("Selecteur du menu")] private GameObject m_menuSelector;
    
    [Header("Animations")]
    [SerializeField] [Tooltip("vitesse d'alternance d'opacité du bouton de lancement de menu")] [Range(0f, 5f)] private float m_launchOpacitySpeed = 1.0f;
    [SerializeField] [Tooltip("vitesse d'apparition for the title (unit : seconds)")] [Range(0f, 10f)] private float m_opacityDuration = 1.0f;
    private bool m_isFading = true;
    private bool m_mainMenuIsActive = false;  //indique si le menu est visible ou nons
    private bool m_language = false;  //ipermet le changement de langue du jeu
    
    [Header("Move")]
    [Tooltip("position limite de joystick")] private float m_limitPosition = 0.5f;
    [HideInInspector] [Tooltip("variable de déplacement en points par points du sélecteur")] private bool m_hasMoved = false;
    //index du sélecteur
    private int m_selectorIndex = 0;
    
    private float m_timer = 0f;  //temps qui s'écoule à chaque frame

    
    // Start is called before the first frame update
    void Start()
    {
        if (m_title == null) Debug.LogError("OUPS ! U FORGOT TO PUT THE TITLE IMAGE ON THE START MANAGER OBJECT");
        if (m_pressStartButton == null) Debug.LogError("OUPS ! U FORGOT TO PUT THE BUTTON TO LAUNCH THE GAME ON THE START MANAGER OBJECT");
        if (m_mainMenu == null) Debug.LogError("OUPS ! U FORGOT TO PUT THE PRINCIPAL MENU ON THE START MANAGER OBJECT");
        
        //On rend invisible les éléments au départ
        m_mainMenu.SetActive(false);

        m_pressStartText = m_pressStartButton.GetComponentInChildren<TextMeshProUGUI>();  //Récupération de la couleur du text du bouton de lancement
        m_pressStartText.color = new Color(1, 1, 1, 0);
        m_title.color = new Color(1, 1, 1, 0);  //le titre est mis en transparence 

        m_menuSelector.transform.position = m_menuPiecesButton[0].transform.position; //Le sélecteur est mis à la première position du menu
    }

    // Update is called once per frame
    void Update(){

        float horizontalAxis = Input.GetAxis("Horizontal");
        float verticalAxis = Input.GetAxis("Vertical");
        bool selectorValidation = Input.GetKeyDown(KeyCode.JoystickButton1);   //Joystick1Button1 est le bouton croix manette PS4

        if (m_isFading) m_timer += Time.deltaTime; //récupération du temps qui s'écoule
        else if(m_timer < m_opacityDuration) m_timer = m_opacityDuration;


        /////////////////////////////       START ANIMATIONS        /////////////////////////////
        
        
        
        //animation d'opacité du titre
        if (m_isFading)
        {
            //changement d'opacité
            m_title.color += new Color(0, 0, 0, Time.deltaTime/m_opacityDuration);   //le deuxième paramètre de mathf.pow est une puissance de 10
            m_pressStartText.color += new Color(0, 0, 0, Time.deltaTime * (1/m_opacityDuration));
            //Arrêt de fade
            if (m_timer >= m_opacityDuration || (Input.GetKeyDown(KeyCode.JoystickButton9) || Input.GetKeyDown(KeyCode.JoystickButton1))) {
                m_isFading = false;
                m_title.color = new Color(1, 1, 1, 1);
                m_pressStartText.color = new Color(1, 1, 1, 1);
            }
            
            //Debug.Log($"{m_isFading}");
        }
        
        //apparition du bouton permettant d'accéder au menu principal si l'animation est terminée
        if (!m_isFading && !m_mainMenuIsActive)
        {
            m_pressStartButton.gameObject.SetActive(true);
            
            //animation d'opacité
            m_pressStartText.color = new Color(255, 255, 255, Mathf.PingPong(Time.time, m_launchOpacitySpeed));

            //accès au menu principal après input sur le bouton start ou le bouton croix
            if ((Input.GetKeyDown(KeyCode.JoystickButton9) || Input.GetKeyDown(KeyCode.JoystickButton1)) && m_timer >= m_opacityDuration)
            {
                m_mainMenu.SetActive(true);
                m_mainMenuIsActive = true;
                m_pressStartButton.gameObject.SetActive(false);
            }
        }

        
        /////////////////////////////       MENU MOVEMENTS        /////////////////////////////
        
        Debug.Log($"{m_selectorIndex}");
        
        if (m_mainMenuIsActive)
        {
            if (!m_hasMoved && horizontalAxis < -m_limitPosition || horizontalAxis > m_limitPosition || verticalAxis > m_limitPosition || verticalAxis < -m_limitPosition)
            {
                //déplacement du sélecteur avec le joystick gauche
                if (!m_hasMoved && verticalAxis > m_limitPosition && m_selectorIndex>0) //Déplacement sur le bouton au-dessus de celui actuellement
                {
                    m_selectorIndex--;
                    m_menuSelector.transform.position = m_menuPiecesButton[m_selectorIndex].transform.position;
                    m_hasMoved = true;
                }
                else if (!m_hasMoved && verticalAxis < -m_limitPosition && m_selectorIndex<m_menuPiecesButton.Length-1) //Déplacement sur le bouton en-dessous de celui actuellement
                {
                    m_selectorIndex++;
                    m_menuSelector.transform.position = m_menuPiecesButton[m_selectorIndex].transform.position;
                    m_hasMoved = true;
                }
            }

            
            if (selectorValidation) {

                switch (m_selectorIndex) {
                    case 0: //Continue
                        break;
                    case 1: //New Game
                        break;
                    case 2: //Language
                        break;
                    case 3: //Quit
                        Application.Quit();
                        break;
                    default: 
                        Debug.LogError("AAAAAAAAAAAAAAHHHHHHHHH   (contact niels if this error occurs)"); 
                        break;
                }
                
            }

            if (m_selectorIndex == 2 && selectorValidation)
            {
                m_mainMenuIsActive = false;
                m_mainMenu.SetActive(false);
                m_language = true;
            }
            
            //Joystick se recentre sur la manette, déplacement par à coup
            if (horizontalAxis < m_limitPosition && horizontalAxis > -m_limitPosition && verticalAxis < m_limitPosition && verticalAxis > -m_limitPosition)
            {
                m_hasMoved = false;
            }
        }


    }
    
    
}
