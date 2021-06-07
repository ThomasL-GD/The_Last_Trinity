using System;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Controls;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class Start_Manager : MonoBehaviour {

    [Serializable] public class Menu {
        public Transform continuer = null;
        public Transform nouvellePartie = null;
        public Transform options = null;
        public Transform quitter = null;
        public Transform continueGame = null;
        public Transform newGame = null;
        public Transform settings = null;
        public Transform quit = null;

        [HideInInspector] public Transform[] frenchMenu = null;
        [HideInInspector] public Transform[] englishMenu = null;
        [HideInInspector] public Transform[] allMenus = null;

        public void BuildArrays() {
            allMenus = new Transform[8] {continuer, nouvellePartie, options, quitter, continueGame, newGame, settings, quit};
        }
    }
    
    
    [Header("Canvas")] 
    [Tooltip("image de Titre")] public Image m_title;
    [SerializeField] [Tooltip("Bouton de démarrage")] private Button m_pressStartButton =null;
    [SerializeField] [Tooltip("texte de démarrage")] private TextMeshProUGUI m_pressStartText=null;
    [SerializeField] [Tooltip("Menu Principal")] private GameObject m_mainMenu=null;
    [SerializeField] [Tooltip("Liste des positions sur lesquelles on va se déplacer ")] private Menu m_languagesMenu = new Menu();
    [SerializeField] [Tooltip("UImage that shows the user he has no gamepad plugged in")] private GameObject m_missingGamepadScreen = null;
    
    private int m_sceneIndex = 0;
    
    [Header("Animations")]
    [SerializeField] [Tooltip("vitesse d'alternance d'opacité du bouton de lancement de menu")] [Range(0f, 5f)] private float m_launchOpacitySpeed = 1.0f;
    [SerializeField] [Tooltip("vitesse d'apparition for the title (unit : seconds)")] [Range(0f, 10f)] private float m_opacityDuration = 1.0f;
    [SerializeField] [Tooltip("The time taken by the fade in black to occur\nUnit : seconds")] [Range(0.5f, 10f)] private float m_fadeTime = 4f;
    [SerializeField] [Tooltip("The canvas of the scene")] private GameObject m_canvas = null;
    private Image m_image = null;
    private bool m_isFading = true;
    private bool m_englishMenuIsActive = false;  //indique si le menu anglais est visible ou non
    private bool m_frenchMenuIsActive = false;  //indique si le menu français est visible ou non
    private bool m_isLaunchingGame = false;
    private bool m_isGamepadPlugged = false;
    private Vector3 m_travelToBack = Vector3.zero; //The vector that represents the travel from original to back position

    [Header("Menu Evolutif")]
    [SerializeField] [Tooltip("The thing to make appear on the first setup (When you first launch the game)\nMust be an empty unactive gameObject with all the things you need in child")] private GameObject m_fisrtSetup = null;
    [SerializeField] [Tooltip("The thing to make appear on the second setup (When the player has encountered all the characters)\nMust be an empty unactive gameObject with all the things you need in child")] private GameObject m_secondSetup = null;
    [SerializeField] [Tooltip("The thing to make appear on the third setup (When the player has finished the game)\nMust be an empty unactive gameObject with all the things you need in child")] private GameObject m_thirdSetup = null;
    
    [Header("Move")]
    [Tooltip("position limite de joystick")] private float m_limitPosition = 0.5f;
    [HideInInspector] [Tooltip("variable de déplacement en points par points du sélecteur")] private bool m_hasMoved = false;
    private int m_selectorIndex = 0;    //index du sélecteur
    
    [Header("Waypoints Manager")]
    [SerializeField] [Tooltip("The list of points the guard will travel to, in order from up to down and cycling")] private List<GameObject> m_destinationsTransforms = new List<GameObject>();
    private List<Vector3> m_destinations = new List<Vector3>();
    [SerializeField] [Tooltip("camera principale")] private GameObject m_camera;
    [SerializeField] [Tooltip("Temps de déplacement de la camera jusqu'à la position de recul")] [Range(0.0f,50.0f)]private float m_backTimeCamera = 1.0f;
    [SerializeField] [Tooltip("vitesse de rotation de la camera jusqu'à la position de recul")] [Range(0.0f,500.0f)] private float m_backSpeedRotationCamera = 100.0f;
    [SerializeField] [Tooltip("temps de déplacement de la camera")] [Range(5.0f,60.0f)] private float m_endTimeCamera = 10.0f;
    private Vector3 m_distance = Vector3.zero;
    private Vector3 m_angle = Vector3.zero;
    
    private float m_timer = 0f;  //temps qui s'écoule à chaque frame
    private float m_timerBackCamera = 0f;  //temps qui s'écoule à chaque frame pendant le travelling vers l'arrière
    private float m_cosine = 0f;  //temps qui s'écoule à chaque frame pendant le travelling vers l'arrière

    [SerializeField] [Tooltip("not supposed to exist")] [Range(0.0f,1.0f)] private float m_multiplier = 2f;

    
    // Start is called before the first frame update
    void Awake() {
        Initialization();

        if (Rumbler.Instance.m_gamepad == null) {
            m_isGamepadPlugged = false;
            m_missingGamepadScreen.SetActive(true);
        }else {
            m_isGamepadPlugged = true;
            m_missingGamepadScreen.SetActive(false);
        }

    }


    void Initialization()
    {

        switch (PlayerPrefs.GetInt("Level", 0)) {
            case 0 :
            case 1 :
                m_fisrtSetup.SetActive(true);
                m_secondSetup.SetActive(false);
                m_thirdSetup.SetActive(false);
                break;
            
            case 2 :
            case 3:
                m_fisrtSetup.SetActive(false);
                m_secondSetup.SetActive(true);
                m_thirdSetup.SetActive(false);
                break;
            
            case 4:
                m_fisrtSetup.SetActive(false);
                m_secondSetup.SetActive(false);
                m_thirdSetup.SetActive(true);
                break;
        }
        
        if (m_title == null) Debug.LogError("OUPS ! U FORGOT TO PUT THE TITLE IMAGE ON THE START MANAGER OBJECT");
        if (m_pressStartButton == null) Debug.LogError("OUPS ! U FORGOT TO PUT THE START BUTTON ON THE START MANAGER OBJECT");
        if (m_pressStartText == null) Debug.LogError("OUPS ! U FORGOT TO PUT THE TEXT OF THE PRESS START BUTTON ON THE START MANAGER OBJECT");
        if (m_mainMenu == null) Debug.LogError("OUPS ! U FORGOT TO PUT THE MAIN MENU ON THE START MANAGER OBJECT");
        
        m_mainMenu.SetActive(false);
        m_languagesMenu.BuildArrays();
        foreach (Transform trans in m_languagesMenu.allMenus) {
            trans.gameObject.SetActive(false);
            trans.gameObject.GetComponent<Image>().color = new Color(0, 0, 0, 0);
        }
        m_languagesMenu.allMenus[4].gameObject.GetComponent<Image>().color = Color.white;

        ////////// BOUTON D'ACCES AU MENU PRINCIPAL ////////////
        m_pressStartText = m_pressStartButton.GetComponentInChildren<TextMeshProUGUI>();  //Récupération de la couleur du text du bouton de lancement
        m_pressStartText.color = new Color(1, 1, 1, 0);
        m_title.color = new Color(1, 1, 1, 0);  //le titre est mis en transparence 
        
        
        ///////// CAMERA BASE SETTINGS //////////
        if (m_destinationsTransforms.Count < 3) Debug.LogError("OH NO, U FORGOT TO PUT THE WAYPOINTS FOR THE TRAVELLING OF THE CAMERA !!!");
        if (m_camera == null) Debug.LogError("OH NO, U FORGOT TO ADD A CAMERA FOR THE TRAVELLING OF THE CAMERA !!!");
        
        //Deux points servant de transfère de la caméra
        for (int i = 0; i < m_destinationsTransforms.Count; i++)
        {
            m_destinations.Add(m_destinationsTransforms[i].transform.position);
        }
        
        //La camera se positionne au même emplacement que le premier GameObject de la liste créée au-dessus
        m_camera.transform.position = m_destinationsTransforms[2].transform.position;

        m_travelToBack = m_destinationsTransforms[1].transform.position - transform.position;
        
        ////PANEL FOR FADE IN BLACK//////
        if (m_canvas == null) {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO SERIALIZE THE CANVAS ON THE END OF THE LEVEL");
        }
        
        //We create a panel that we will fade in black
        GameObject child = Instantiate(new GameObject(), m_canvas.transform);
        child.name = "Fade in Black";
        RectTransform rect = child.AddComponent<RectTransform>();
        Image image = child.AddComponent<Image>();
        
        //We set the rect transform in order to cover the whole screen
        rect.anchorMin = new Vector2(0f, 0f);
        rect.anchorMax = new Vector2(1f, 1f);
        rect.localPosition = Vector3.zero;
        rect.anchoredPosition = Vector2.zero;
        
        //We make the panel fully transparent... for now...
        image.color = new Color(0f,0f,0f, 0f);
        m_image = image;
        
    }

    // Update is called once per frame
    void Update()
    {

        if (!m_isGamepadPlugged) {
            Gamepad gamepad = Rumbler.Instance.GetGamepad();
            if (gamepad == null) return;
            else {
                m_isGamepadPlugged = true;
                m_missingGamepadScreen.SetActive(false);
                return;
            }
        }

        float horizontalAxis = Input.GetAxis("Horizontal");
        float verticalAxis = Input.GetAxis("Vertical");
        bool selectorValidation = Input.GetKeyDown(KeyCode.JoystickButton1);   //Joystick1Button1 est le bouton croix manette PS4
        
        bool left = ((!m_hasMoved && horizontalAxis < -m_limitPosition) || Rumbler.Instance.GetDpad().left.wasPressedThisFrame);
        bool right = ((!m_hasMoved && horizontalAxis > m_limitPosition) || Rumbler.Instance.GetDpad().right.wasPressedThisFrame);
        bool up = ((!m_hasMoved && verticalAxis > m_limitPosition) || Rumbler.Instance.GetDpad().up.wasPressedThisFrame);
        bool down = ((!m_hasMoved && verticalAxis < -m_limitPosition) || Rumbler.Instance.GetDpad().down.wasPressedThisFrame);

        
        /////////////////////////////       MENU MOVEMENTS        /////////////////////////////
        
        
        //DEPLACEMENT DU CURSEUR si le menu adequat est actif
        if (m_englishMenuIsActive || m_frenchMenuIsActive) {
            if (left || right || up || down) {
                int shift = 0;
                if (m_englishMenuIsActive) shift = 4;
                
                m_languagesMenu.allMenus[m_selectorIndex + shift].GetComponent<Image>().color = new Color(0, 0, 0, 0);
                
                //déplacement du sélecteur avec le joystick gauche
                if (up && m_selectorIndex > 0) //Déplacement sur le bouton au-dessus de celui actuellement
                {
                    m_selectorIndex--;
                    m_hasMoved = true;
                }
                else if (down && m_selectorIndex < 3) //Déplacement sur le bouton en-dessous de celui actuellement
                {
                    m_selectorIndex++;
                    m_hasMoved = true;
                }

                m_languagesMenu.allMenus[m_selectorIndex + shift].GetComponent<Image>().color = Color.white;
                
            }

            //RESET POUR DEPLACEMENT PAR A COUPS
            if (horizontalAxis < m_limitPosition && horizontalAxis > -m_limitPosition && verticalAxis < m_limitPosition && verticalAxis > -m_limitPosition) {
                m_hasMoved = false;
            }
            
            //INPUT D'ACTIVATION A L'ENDROIT OU LE CURSEUR SE SITUE
            if (selectorValidation) {

                switch (m_selectorIndex) {
                    case 0: //Continue
                        //If the player has not reached the end of the game yet, we launch the level they are currently at, else, we launch the last level once again
                        int sceneID = PlayerPrefs.GetInt("Level", 1);
                        if (sceneID < 4) m_sceneIndex = sceneID;
                        else m_sceneIndex = 3;
                        m_isLaunchingGame = true;
                        break;
                    case 1: //New Game
                        m_isLaunchingGame = true;
                        int nextScene = SceneManager.GetActiveScene().buildIndex + 1;
                        //If the player chooses new game, we reset his save
                        PlayerPrefs.SetInt("Level", nextScene);
                        m_sceneIndex = nextScene;
                        break;
                    case 2: //Language
                        if (m_englishMenuIsActive) {
                            Debug.Log("Vers le francais");
                            m_englishMenuIsActive = false;
                            m_frenchMenuIsActive = true;
                            for (int i = 0; i < m_languagesMenu.allMenus.Length; i++) {

                                if (i < 4) {
                                    m_languagesMenu.allMenus[i].gameObject.SetActive(true);
                                    if(i == m_selectorIndex)m_languagesMenu.allMenus[i].gameObject.GetComponent<Image>().color = Color.white;
                                }
                                else {
                                    m_languagesMenu.allMenus[i].gameObject.SetActive(false);
                                    if(i == m_selectorIndex)m_languagesMenu.allMenus[i].gameObject.GetComponent<Image>().color = new Color(0,0,0,0);
                                }
                            }
                        }
                        else if (m_frenchMenuIsActive) {
                            Debug.Log("Vers l'anglais");
                            m_frenchMenuIsActive = false;
                            m_englishMenuIsActive = true;
                            for (int i = 0; i < m_languagesMenu.allMenus.Length; i++) {

                                if (i > 3) {
                                    m_languagesMenu.allMenus[i].gameObject.SetActive(true);
                                    if(i == m_selectorIndex)m_languagesMenu.allMenus[i+4].gameObject.GetComponent<Image>().color = Color.white;
                                }
                                else {
                                    m_languagesMenu.allMenus[i].gameObject.SetActive(false);
                                    if(i == m_selectorIndex)m_languagesMenu.allMenus[i].gameObject.GetComponent<Image>().color = new Color(0,0,0,0);
                                }
                            }
                        }
                        break;
                    case 3:
                        Application.Quit();
                        break;
                    default: 
                        Debug.LogError("AAAAAAAAAAAAAAHHHHHHHHH   (contact niels if this error occurs)"); 
                        break;
                }
            }
        }
        
        //////////////////Animations Ecran/////////////////////////
        if (m_isFading) m_timer += Time.deltaTime; //récupération du temps qui s'écoule
        else if(m_timer < m_opacityDuration) m_timer = m_opacityDuration;   //Arrêt du timer après visibilité totale


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
                
                m_mainMenu.SetActive(true);
                m_englishMenuIsActive = true;
                for (int i = 4; i < m_languagesMenu.allMenus.Length; i++) {
                    //We active the indexes from 4 to 7
                    m_languagesMenu.allMenus[i].gameObject.SetActive(true);
                }
                m_pressStartButton.gameObject.SetActive(false);
                
                //Prearation for the next travelling
                m_distance = m_destinationsTransforms[2].transform.position - m_camera.transform.position;
                m_angle = m_destinationsTransforms[2].transform.rotation.eulerAngles - m_camera.transform.rotation.eulerAngles;
                m_timerBackCamera = 0.0f;
            }
        }
        
        
        /////////////////////////////       ANIMATION CAMERA       /////////////////////////////


        if (!m_englishMenuIsActive && !m_frenchMenuIsActive) {
            
            //we cap the movement and replace it with a ping-pong once we reached the target position
            if (m_timerBackCamera < m_backTimeCamera) {
                //déplacement de la caméra de la position initiale à la position de recul
                m_camera.transform.position += m_travelToBack * (Time.deltaTime/m_backTimeCamera);

                m_timerBackCamera += Time.deltaTime;
            }
            else { //Once we've reached the back point, we just hang in there
                m_cosine += Time.deltaTime * m_multiplier;
                m_camera.transform.position += m_travelToBack * ((Time.deltaTime/m_backTimeCamera) * Mathf.Cos(m_cosine));
                //Debug.Log(Mathf.Cos(m_cosine));
            }
            
            
            //rotation de la caméra sur la durée pour avoir la même que la rotation de la vue de recul
            if (m_camera.transform.rotation.x >= m_destinationsTransforms[1].transform.rotation.x) {
                m_camera.transform.Rotate(Vector3.left * (m_backSpeedRotationCamera * Time.deltaTime));
            }
        }
        else if((m_englishMenuIsActive || m_frenchMenuIsActive) && m_timerBackCamera < m_endTimeCamera){ // If the main menu is active and the camera still have travel to do to go to its target position
            m_timerBackCamera += Time.deltaTime;
            
            //déplacement de la caméra vers la position souhaitée
            m_camera.transform.position += m_distance * (Time.deltaTime/m_endTimeCamera);
            //rotation de la caméra vers la position souhaitée
            m_camera.transform.rotation = Quaternion.Euler(m_camera.transform.rotation.eulerAngles     +    m_angle * (Time.deltaTime/m_endTimeCamera));

        }
        
        
        //////////FADING/////////

        //If the player has reached the end, we fade in black and once it's faded, we start the next scene
        if (m_isLaunchingGame) {
            float newAlpha = m_image.color.a + Time.deltaTime / m_fadeTime;

            if (newAlpha >= 1f) {
                //If the color will go above one, we set it to one instead and launch the next scene
                m_image.color = new Color(0f,0f,0f, 1f);
                PlayerPrefs.Save();
                SceneManager.LoadScene(m_sceneIndex);
            }
            else m_image.color = new Color(0f,0f,0f, newAlpha);
        }
        
    }
    
    
    
    
    
    
}
