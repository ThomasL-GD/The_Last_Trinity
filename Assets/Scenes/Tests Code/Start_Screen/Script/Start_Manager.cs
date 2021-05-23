using System;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class Start_Manager : MonoBehaviour
{
    /*
    [Serializable]
    public class ButtonsMenu
    {
        //Anglais
        [SerializeField] [Tooltip("bouton anglais de continuation")] public GameObject m_continue =null;
        [SerializeField] [Tooltip("bouton anglais de nouvelle partie")] public GameObject m_newGame =null;
        [SerializeField] [Tooltip("bouton anglais de changement de langue")] public GameObject m_language =null;
        [SerializeField] [Tooltip("bouton anglais de quitter le jeu")] public GameObject m_quit =null;
        
        //Français
        [SerializeField] [Tooltip("bouton français de continuation")] public GameObject m_continuer =null;
        [SerializeField] [Tooltip("bouton français de nouvelle partie")] public GameObject m_nouvellePartie =null;
        [SerializeField] [Tooltip("bouton français de changement de langue")] public GameObject m_langue =null;
        [SerializeField] [Tooltip("bouton français de quitter le jeu")] public GameObject m_quitter =null;
    }
    */
    
    //[SerializeField] [Tooltip("Tableau des pièces à instancier avec leur nom")] private ButtonsMenu m_buttonsMenu=null;
    
    
    [Header("Canvas")] 
    [Tooltip("image de Titre")] public Image m_title;
    [SerializeField] [Tooltip("Bouton de démarrage")] private Button m_pressStartButton =null;
    [SerializeField] [Tooltip("texte de démarrage")] private TextMeshProUGUI m_pressStartText=null;
    [SerializeField] [Tooltip("Menu Principal")] private GameObject m_englishMainMenu =null;
    [SerializeField] [Tooltip("Menu Principal")] private GameObject m_frenchMainMenu=null;
    [SerializeField] [Tooltip("Menu Principal")] private GameObject m_mainMenu=null;
    //[SerializeField] [Tooltip("Liste des positions sur lesquelles on va se déplacer ")] private GameObject[] m_menuPiecesButton;
    //[SerializeField] [Tooltip("Liste des positions sur lesquelles on va se déplacer ")] private List<GameObject> m_menuPiecesButton = new List<GameObject>();
    [SerializeField] [Tooltip("Liste des positions sur lesquelles on va se déplacer ")] private List<Transform> m_test = new List<Transform>();
    

    [Header("Buttons Menu")]
    [SerializeField] [Tooltip("bouton anglais de continuation")] public GameObject m_continue =null;
    [SerializeField] [Tooltip("bouton anglais de nouvelle partie")] public GameObject m_newGame =null;
    [SerializeField] [Tooltip("bouton anglais de changement de langue")] public GameObject m_language =null;
    [SerializeField] [Tooltip("bouton anglais de quitter le jeu")] public GameObject m_quit =null;
    
    [Header("Menu Selector")] 
    [SerializeField] [Tooltip("Selecteur du menu")] private GameObject m_englishMenuSelector;
    [SerializeField] [Tooltip("Selecteur du menu")] private GameObject m_frenchMenuSelector;
    [SerializeField] [Tooltip("Selecteur du menu")] private GameObject m_menuSelector;
    
    [Header("Animations")]
    [SerializeField] [Tooltip("vitesse d'alternance d'opacité du bouton de lancement de menu")] [Range(0f, 5f)] private float m_launchOpacitySpeed = 1.0f;
    [SerializeField] [Tooltip("vitesse d'apparition for the title (unit : seconds)")] [Range(0f, 10f)] private float m_opacityDuration = 1.0f;
    private bool m_isFading = true;
    private bool m_englishMenuIsActive = false;  //indique si le menu anglais est visible ou non
    private bool m_frenchMenuIsActive = false;  //indique si le menu français est visible ou non
    
    [Header("Move")]
    [Tooltip("position limite de joystick")] private float m_limitPosition = 0.5f;
    [HideInInspector] [Tooltip("variable de déplacement en points par points du sélecteur")] private bool m_hasMoved = false;
    private int m_selectorIndex = 0;    //index du sélecteur
    
    private float m_timer = 0f;  //temps qui s'écoule à chaque frame

    
    // Start is called before the first frame update
    void Start()
    {
        if (m_title == null) Debug.LogError("OUPS ! U FORGOT TO PUT THE TITLE IMAGE ON THE START MANAGER OBJECT");
        if (m_pressStartButton == null) Debug.LogError("OUPS ! U FORGOT TO PUT THE BUTTON TO LAUNCH THE GAME ON THE START MANAGER OBJECT");
        if (m_englishMainMenu == null) Debug.LogError("OUPS ! U FORGOT TO PUT THE ENGLISH MENU ON THE START MANAGER OBJECT");
        if (m_frenchMainMenu == null) Debug.LogError("OUPS ! U FORGOT TO PUT THE FRENCH MENU ON THE START MANAGER OBJECT");
        
        //On rend invisible les éléments au départ
        m_englishMainMenu.SetActive(false);
        m_frenchMainMenu.SetActive(false);
        m_mainMenu.SetActive(false);

        m_pressStartText = m_pressStartButton.GetComponentInChildren<TextMeshProUGUI>();  //Récupération de la couleur du text du bouton de lancement
        m_pressStartText.color = new Color(1, 1, 1, 0);
        m_title.color = new Color(1, 1, 1, 0);  //le titre est mis en transparence 

        /*
        m_menuPiecesButton = new GameObject[8];

        m_menuPiecesButton[0] = m_buttonsMenu.m_continue;
        m_menuPiecesButton[1] = m_buttonsMenu.m_newGame;
        m_menuPiecesButton[2] = m_buttonsMenu.m_language;
        m_menuPiecesButton[3] = m_buttonsMenu.m_quit;
        m_menuPiecesButton[4] = m_buttonsMenu.m_continuer;
        m_menuPiecesButton[5] = m_buttonsMenu.m_nouvellePartie;
        m_menuPiecesButton[6] = m_buttonsMenu.m_langue;
        m_menuPiecesButton[7] = m_buttonsMenu.m_quitter;
        */
        
        //m_englishMenuSelector.transform.position = m_menuPiecesButton[4].transform.position; //Le sélecteur anglais est mis à la première position du menu
        //m_frenchMenuSelector.transform.position = m_menuPiecesButton[6].transform.position; //Le sélecteur français est mis au niveau du changement de langue du menu

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
        if (!m_isFading && !m_englishMenuIsActive && !m_frenchMenuIsActive)
        {
            m_pressStartButton.gameObject.SetActive(true);
            
            //animation d'opacité
            m_pressStartText.color = new Color(255, 255, 255, Mathf.PingPong(Time.time, m_launchOpacitySpeed));

            //accès au menu principal après input sur le bouton start ou le bouton croix
            if ((Input.GetKeyDown(KeyCode.JoystickButton9) || Input.GetKeyDown(KeyCode.JoystickButton1)) && m_timer >= m_opacityDuration)
            {
                //m_englishMainMenu.SetActive(true);
                m_mainMenu.SetActive(true);
                m_englishMenuIsActive = true;
                for (int i = 4; i < m_test.Count; i++)
                {
                    m_test[i].gameObject.SetActive(false);
                }
                m_pressStartButton.gameObject.SetActive(false);
            }
        }

        
        /////////////////////////////       MENU MOVEMENTS        /////////////////////////////
        
        
        Debug.Log($"{m_selectorIndex}");
        //Debug.Log($" anglais : {m_englishMenuIsActive}    et francais : {m_frenchMenuIsActive}");
        
        if (!m_hasMoved && horizontalAxis < -m_limitPosition || horizontalAxis > m_limitPosition || verticalAxis > m_limitPosition || verticalAxis < -m_limitPosition)
        {
            //déplacement du sélecteur avec le joystick gauche
            if (!m_hasMoved && verticalAxis > m_limitPosition && m_selectorIndex > 0) //Déplacement sur le bouton au-dessus de celui actuellement
            {
                m_selectorIndex--;
                m_menuSelector.transform.position = m_test[m_selectorIndex].transform.position;
                m_hasMoved = true;
            }
            else if (!m_hasMoved && verticalAxis < -m_limitPosition && m_selectorIndex < 3) //Déplacement sur le bouton en-dessous de celui actuellement
            {
                m_selectorIndex++;
                m_menuSelector.transform.position = m_test[m_selectorIndex].transform.position;
                m_hasMoved = true;
            }
        }

        //Joystick se recentre sur la manette, déplacement par à coup
        if (horizontalAxis < m_limitPosition && horizontalAxis > -m_limitPosition && verticalAxis < m_limitPosition && verticalAxis > -m_limitPosition)
        {
            m_hasMoved = false;
        }

        if (m_englishMenuIsActive)
        {
            for (int i = 4; i < m_test.Count; i++)
            {
                if(i<4) m_test[i].gameObject.SetActive(true);
                else m_test[i].gameObject.SetActive(false);
            }
                
        }
        else if (m_frenchMenuIsActive)
        {
            for (int i = 4; i < m_test.Count; i++)
            {
                if(i>3) m_test[i].gameObject.SetActive(true);
                else m_test[i].gameObject.SetActive(false);
            }
        }
        
        if (selectorValidation) {

            switch (m_selectorIndex) {
                case 0: //Continue
                    break;
                case 1: //New Game
                    break;
                case 2: //Language
                    if (m_englishMenuIsActive)
                    {
                        Debug.Log("Vers le francais");
                        m_englishMenuIsActive = false;
                        m_frenchMenuIsActive = true;
                    }
                    else if (m_frenchMenuIsActive)
                    {
                        Debug.Log("Vers l'anglais");
                        m_frenchMenuIsActive = false;
                        m_englishMenuIsActive = true;
                    }
                    break;
                default: 
                    Debug.LogError("AAAAAAAAAAAAAAHHHHHHHHH   (contact niels if this error occurs)"); 
                    break;
            }
        }

    }
    
    
}
