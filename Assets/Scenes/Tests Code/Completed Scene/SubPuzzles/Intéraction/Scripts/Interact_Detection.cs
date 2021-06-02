using System;
using System.Collections;
using UnityEngine;

public class Interact_Detection : MonoBehaviour
{

    [System.Serializable]
    public class MovableDoor {
        public string m_name = "Unnamed adopted door";
        public GameObject m_door = null;
        public Vector3 m_positionToGo = Vector3.zero;
        [HideInInspector] public Vector3 m_velocity = Vector3.zero;

        public MovableDoor(string p_name, GameObject p_door, Vector3 p_pos) {
            m_name = p_name;
            m_door = p_door;
            m_positionToGo = p_pos;
        }
    }
    

    [Header("Player")]
    [SerializeField] [Tooltip("personnage qui fait le subpuzzle")] private Charas m_chara = 0;
    [SerializeField] [Tooltip("Main Camera devrait marcher")] private Transform m_camera;
    [SerializeField] [Tooltip("boutons d'intéractions de la manette")] private SOInputMultiChara m_inputs = null;
    [Tooltip("script chara")] private PlayerController m_playerController = null;

    [Header("Puzzle")]
    [SerializeField] [Tooltip("subpuzzle qu'on souhaite faire apparaitre")] private GameObject m_puzzle;
    [HideInInspector] [Tooltip("indicateur de réussite de subPuzzle")] public bool m_achieved = false;
    [HideInInspector] [Tooltip("variable qui autorise le déplacement dans le subPuzzle")] public bool m_canMove = true;
 
    [Header("Activation Button")]
    [HideInInspector] [Tooltip("variable booléènne qui indique le passage entre le jeu et sub puzzle")] public bool m_isInSubPuzzle = false;
    [SerializeField] [Tooltip("Bouton qui apparait afin de déclencher le puzzle")] private GameObject m_activationButton;
    [HideInInspector] [Tooltip("contrôle d'état du trigger du bouton permettant d'activer le sub puzzle")] private bool m_buttonActivate = false;
    
    [Header("Open Door")]
    [HideInInspector] public bool m_openDoor = false;
    [SerializeField] [Tooltip("List of Door to open, if empty, won't open any door")] private MovableDoor[] m_doorSub = new MovableDoor[]{}; //Liste de portes à ouvrir lorsque le puzzle est réussi
    [SerializeField] [Tooltip("The time taken by each door to open (unit : seconds)")] [Range(0f,5f)] private float m_doorOpeningTime = 2f; //Vitesse d'ouverture des portes
    [SerializeField] [Tooltip("Temps que l'écran de fin reste activé quand le subpuzzle est réussit (unit : seconds)")] [Range(0f,5f)] private float m_timer = 1f;
    
    
    private void Start()
    {
        if (m_puzzle == null) { Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO ADD A SUBPUZZLE IN INTERACT_DETECTION !", this);
        }
        else {
            switch (m_chara) {
                case Charas.Human:
                    if (!m_puzzle.TryGetComponent(out HumanSubPuzzle hsb)) Debug.LogError("JEEZ ! THE GAME DESIGNER PUT A SUBPUZZLE DIFFERENT FROM THE CHARA CHOOSED ABOVE IN INTERACT_DETECTION !", this);
                    break;
                case Charas.Monster:
                    if (!m_puzzle.TryGetComponent(out MonsterPuzzle msb)) Debug.LogError("JEEZ ! THE GAME DESIGNER PUT A SUBPUZZLE DIFFERENT FROM THE CHARA CHOOSED ABOVE IN INTERACT_DETECTION !", this);
                    break;
                case Charas.Robot:
                    if (!m_puzzle.TryGetComponent(out RobotPuzzleManager rsb)) Debug.LogError("JEEZ ! THE GAME DESIGNER PUT A SUBPUZZLE DIFFERENT FROM THE CHARA CHOOSED ABOVE IN INTERACT_DETECTION !", this);
                    break;
            }
        }
        
        if(m_timer > m_doorOpeningTime) Debug.LogError ($"JEEZ ! THE M_TIMER ({m_timer}) MUST BE SHORTER THAN THE M_DOOROPENINGTIME ({m_doorOpeningTime}) YOU FREAKING RETARDED !", this);

        if (m_camera == null) Debug.LogError ("JEEZ ! THE GAME DESIGNER FORGOT TO PUT THE CAMERA IN INTERACT_DETECTION !", this);
        if (m_inputs == null) Debug.LogError ("JEEZ ! THE GAME DESIGNER FORGOT TO ADD THE INPUTS IN INTERACT_DETECTION !", this);
        if(m_doorSub.Length == 0) Debug.LogWarning("BE CAREFUL ! THERE IS NO DOOR FOR ANIMATION IN INTERACT_DETECTION !", this);
        
    }

    private void Update()
    {
        if (m_isInSubPuzzle && GuardBehavior.m_isKillingSomeone)
        {
            Debug.Log("Tue moi ce type qui est dans le subpuzzle");
            PuzzleDeactivation();
        }
        
        if (m_buttonActivate || m_isInSubPuzzle) {

            bool input = false;

            if (m_playerController.m_cycle) {
                input = Rumbler.Instance.m_gamepad.buttonSouth.wasPressedThisFrame;
            }
            else if (!m_playerController.m_cycle){
                //input des différents character
                if (m_chara == Charas.Human) input = Input.GetKeyDown(m_inputs.inputHuman); //Gamepad.current.buttonWest.isPressed; 
                else if (m_chara == Charas.Monster) input = Input.GetKeyDown(m_inputs.inputMonster); //Gamepad.current.buttonNorth.isPressed; 
                else if (m_chara == Charas.Robot) input = Input.GetKeyDown(m_inputs.inputRobot); //Gamepad.current.buttonEast.isPressed;
            }
            
            
            if (m_playerController.m_isActive) {
                
                m_activationButton.SetActive(true);

                //Le bouton d'activation regarde toujours en direction de la caméra de jeu
                m_activationButton.transform.LookAt(m_camera);

                //Input et bouton visible ==> entrée dans subpuzzle 
                if (input && m_canMove) {

                    if (m_chara == Charas.Human) {
                        HumanSubPuzzle humanPuzzle = m_puzzle.GetComponent<HumanSubPuzzle>();
                        humanPuzzle.m_interactDetection = this;
                        humanPuzzle.m_cycle = m_playerController.m_cycle;
                    }
                    else if (m_chara == Charas.Monster) {
                        MonsterPuzzle monsterPuzzle = m_puzzle.GetComponent<MonsterPuzzle>();
                        monsterPuzzle.m_interactDetection = this;
                        monsterPuzzle.m_cycle = m_playerController.m_cycle;
                    }
                    else if (m_chara == Charas.Robot) {
                        RobotPuzzleManager robotPuzzle = m_puzzle.GetComponent<RobotPuzzleManager>();
                        robotPuzzle.m_interactDetection = this;
                        robotPuzzle.m_cycle = m_playerController.m_cycle;
                    }

                    
                    m_puzzle.SetActive(true);
                    m_isInSubPuzzle = true;
                    m_playerController.m_isForbiddenToMove = true; //We forbid the movements for the player
                    m_buttonActivate = false;
                }
            }
            else m_activationButton.SetActive(false);
        }
        
        
        if (m_openDoor && m_doorSub.Length > 0) {
            foreach (MovableDoor door in m_doorSub) {
                door.m_door.transform.position = Vector3.SmoothDamp(door.m_door.transform.position, door.m_positionToGo, ref door.m_velocity , m_doorOpeningTime);
            }
        }
    }

    
    /// <summary>
    /// désactivation du script actuel
    /// </summary>
    public void PuzzleDeactivation(bool p_mustKillTheChara = false)
    {
        if (m_achieved)
        {
            StartCoroutine(EndLook());
        }
        else if (GuardBehavior.m_isKillingSomeone)
        {
            m_playerController.m_isForbiddenToMove = true;
            m_activationButton.SetActive(false);
            m_buttonActivate = false;
            m_isInSubPuzzle = false;
            m_puzzle.SetActive(false);
        }
        else {
            m_playerController.m_isForbiddenToMove = false;
            m_activationButton.SetActive(true);
            m_buttonActivate = true;
            m_isInSubPuzzle = false;
            m_puzzle.SetActive(false);
            Debug.Log("Le puzzle doit se fermer");
        }

        if (p_mustKillTheChara) {
            Debug.Log("The subPuzzle killed a chara");
            m_playerController.Death();
        }
    }

    /// <summary>
    /// Temps que le puzzle reste encore actif après réussite
    /// </summary>
    IEnumerator EndLook() {

        m_playerController.m_isForbiddenToMove = false;
        
        yield return new WaitForSeconds(m_timer);

        m_canMove = false;
        m_puzzle.SetActive(false);
        m_isInSubPuzzle = false;
        m_activationButton.SetActive(false);
        m_buttonActivate = false;
        
        if(m_doorSub.Length != 0) StartCoroutine(DoorTimer());
    }

    /// <summary>
    /// Will let the door opens before disable this script
    /// </summary>
    /// <returns></returns>
    IEnumerator DoorTimer() {
        m_openDoor = true;
        PlayerController playerCon = m_playerController;
        playerCon.LookSomewhere(m_doorSub[0].m_door.transform);
        
        yield return new WaitForSeconds(m_doorOpeningTime);
        
        playerCon.Refocus();
        this.enabled = false;
    }
    
    
    /// <summary>
    /// fonction de détection de collision entre le joueur et différents objets
    /// </summary>
    /// <param name="p_other"></param>
    private void OnTriggerEnter(Collider p_other)
    {
        //détection d'un objet de type sub puzzle
        if (!m_isInSubPuzzle && p_other.gameObject.TryGetComponent(out PlayerController charaScript))
        {
            if (charaScript.m_chara == m_chara && !m_achieved) {
                m_playerController = charaScript;
                m_activationButton.SetActive(true);
                m_buttonActivate = true;
            }
        }
    }
    
    /// <summary>
    /// Bouton d'activation de sub puzzle se désactive si le joueur est trop loin
    /// </summary>
    /// <param name="p_other"></param>
    private void OnTriggerExit(Collider p_other)
    {
        //mm_playerController = null;
        m_activationButton.SetActive(false);
        m_buttonActivate = false;
    }
    
    /// <summary>
    /// Resize the current GameObject (must be a panel) in order to be a square without going out of the screen
    /// </summary>
    public void SquarePanelToScreen()
    {
        if (m_puzzle.TryGetComponent(out RectTransform thisRect)) 
        {
            thisRect.anchorMax = new Vector2(0.5f, 0.5f);
            thisRect.anchorMin = new Vector2(0.5f, 0.5f);
			
            if (Screen.width >= Screen.height) {
                thisRect.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, Screen.height);
                thisRect.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, Screen.height);
            } 
            else {
                Debug.Log("Dang it, that's a weird monitor you got there");
                thisRect.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, Screen.width);
                thisRect.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, Screen.width);
            }
            thisRect.localPosition = Vector3.zero;
            thisRect.anchoredPosition = Vector2.zero;
            //Debug.Log(Screen.height);
        } 
        else {
            Debug.LogError ("JEEZ ! THIS SCRIPT IS MEANT TO BE ON A PANEL NOT A RANDOM GAMEOBJECT ! GAME DESIGNER DO YOUR JOB !");
        }
    }
}
