using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SocialPlatforms;

public class Interact_Detection : MonoBehaviour
{

    [Header("Player")]
    [SerializeField] [Tooltip("personnage qui fait le subpuzzle")] private Charas m_chara = 0;
    [SerializeField] [Tooltip("Main Camera devrait marcher")] private Transform m_camera;
    [SerializeField] [Tooltip("boutons d'intéractions de la manette")] private SOInputMultiChara m_inputs = null;
    [Tooltip("script chara")] private PlayerController m_playerController = null;

    [Header("Puzzle")]
    [SerializeField] [Tooltip("subpuzzle qu'on souhaite faire apparaitre")] private GameObject m_puzzle;
 
    [Header("Activation Button")]
    [HideInInspector] [Tooltip("variable booléènne qui indique le passage entre le jeu et sub puzzle")] public bool m_isInSubPuzzle = false;
    [SerializeField] [Tooltip("Bouton qui apparait afin de déclencher le puzzle")] private GameObject m_activationButton;
    [HideInInspector] [Tooltip("contrôle d'état du trigger du bouton permettant d'activer le sub puzzle")] private bool m_buttonActivate = false;
    
    public bool m_openDoor = false;
    [HideInInspector] [Tooltip("indicateur de réussite de subPuzzle")] public bool m_achieved = false;
    [HideInInspector] [Tooltip("variable qui autorise le déplacement dans le subPuzzle")] public bool m_canMove = true;
    [SerializeField] [Tooltip("Temps que l'écran de fin reste activé quand le subpuzzle est réussit")] [Range(0f,500f)] private float m_timer = 1f;
    
    private void Start()
    {
        if (m_puzzle == null) {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO ADD A SUBPUZZLE IN INTERACT_DETECTION !");
        }
        else {
            switch (m_chara) {
                case Charas.Human:
                    if (!m_puzzle.TryGetComponent(out HumanSubPuzzle hsb))
                        Debug.LogError("JEEZ ! THE GAME DESIGNER PUT A SUBPUZZLE DIFFERENT FROM THE CHARA CHOOSED ABOVE IN INTERACT_DETECTION !");
                    break;
                case Charas.Monster:
                    if (!m_puzzle.TryGetComponent(out MonsterPuzzle msb))
                        Debug.LogError("JEEZ ! THE GAME DESIGNER PUT A SUBPUZZLE DIFFERENT FROM THE CHARA CHOOSED ABOVE IN INTERACT_DETECTION !");
                    break;
                case Charas.Robot:
                    if (!m_puzzle.TryGetComponent(out RobotPuzzleManager rsb))
                        Debug.LogError("JEEZ ! THE GAME DESIGNER PUT A SUBPUZZLE DIFFERENT FROM THE CHARA CHOOSED ABOVE IN INTERACT_DETECTION !");
                    break;
            }
        }

        if (m_camera == null) {
            Debug.LogError ("JEEZ ! THE GAME DESIGNER FORGOT TO PUT THE CAMERA IN INTERACT_DETECTION !");
        }
        if (m_inputs == null) {
            Debug.LogError ("JEEZ ! THE GAME DESIGNER FORGOT TO ADD THE INPUTS IN INTERACT_DETECTION !");
        }
        
        
    }

    private void Update()
    {
        if (m_buttonActivate || m_isInSubPuzzle) {
            
            bool input = false;

            //input des différents character
            if (m_chara == Charas.Human) input = Input.GetKeyDown(m_inputs.inputHuman);
            else if (m_chara == Charas.Monster) input = Input.GetKeyDown(m_inputs.inputMonster);
            else if (m_chara == Charas.Robot) input = Input.GetKeyDown(m_inputs.inputRobot);

            if (m_playerController.m_isActive) {

                m_activationButton.SetActive(true);

                //Le bouton d'activation regarde toujours en direction de la caméra de jeu
                m_activationButton.transform.LookAt(m_camera);

                //Input et bouton visible ==> entrée dans subpuzzle 
                if (input) {

                    if (m_chara == Charas.Human) {
                        m_puzzle.GetComponent<HumanSubPuzzle>().m_interactDetection = this;
                    }
                    else if (m_chara == Charas.Monster) {
                        m_puzzle.GetComponent<MonsterPuzzle>().m_interactDetection = this;
                    }
                    else if (m_chara == Charas.Robot) {
                        m_puzzle.GetComponent<RobotPuzzleManager>().m_interactDetection = this;
                    }

                    m_puzzle.SetActive(true);
                    m_isInSubPuzzle = true;
                    m_playerController.m_isForbiddenToMove = true; //We forbid the movements for the player
                    m_buttonActivate = false;
                }
            }
            else m_activationButton.SetActive(false);
            
        }

    }

    
    /// <summary>
    /// désactivation du script actuel
    /// </summary>
    public void PuzzleDeactivation()
    {
        if (m_achieved == true) {
            StartCoroutine(EndLook());
        }
        else {
            m_playerController.m_isForbiddenToMove = false;
            m_activationButton.SetActive(true);
            m_buttonActivate = true;
            m_isInSubPuzzle = false;
            m_puzzle.SetActive(false);
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
        m_activationButton.SetActive(false);
        m_buttonActivate = false;
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
        //m_playerController = null;
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
