using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Interact_Detection : MonoBehaviour
{

    [Header("Player")]
    [SerializeField] [Tooltip("personnage qui fait le subpuzzle")] private Charas m_chara = Charas.Human;
    [SerializeField] [Tooltip("camera à attacher au joueur pour le bouton d'activation au-dessus")] private Transform m_camera;
    [SerializeField] [Tooltip("boutons d'intéractions de la manette")] private SOInputMultiChara m_inputs = null;

    [Header("Puzzle")]
    [SerializeField] [Tooltip("subpuzzle qu'on souhaite faire apparaitre")] private GameObject m_puzzle;
 
    [Header("Activation Button")]
    [HideInInspector] [Tooltip("variable booléènne qui indique le passage entre le jeu et sub puzzle")] public bool m_isInSubPuzzle = false;
    [SerializeField] [Tooltip("Bouton qui apparait afin de déclencher le puzzle")] private GameObject m_activationButton;
    [HideInInspector] [Tooltip("contrôle d'état du trigger du bouton permettant d'activer le sub puzzle")] private bool m_buttonActivate = false;

    public bool m_openDoor = false;
    

    private void Update()
    {
        bool input = false;
        
        //input des différents character
        if (m_chara == Charas.Human)
        {
            input = Input.GetKeyDown(m_inputs.inputHuman);
        }
        else if (m_chara == Charas.Monster)
        {
            input = Input.GetKeyDown(m_inputs.inputMonster);
        }
        else if (m_chara == Charas.Robot)
        {
            input = Input.GetKeyDown(m_inputs.inputRobot);
        }

        
        //Input et bouton visible ==> entrée dans subpuzzle 
        if (input && m_buttonActivate)
        {
            m_puzzle.SetActive(true);
            m_isInSubPuzzle = true;
            m_buttonActivate = false;
            
            if (m_chara == Charas.Human)
            {
                //m_puzzle.GetComponent<HumanSubPuzzle>().m_interacttakapté
            }
            else if (m_chara == Charas.Monster)
            {
                m_puzzle.GetComponent<MonsterPuzzle>().m_interactDetection = this;
            }
            else if (m_chara == Charas.Robot)
            {
                m_puzzle.GetComponent<RobotPuzzleManager>().m_interactDetection = this;
            }
        }
        
        
        //Le bouton d'activation regarde toujours en direction de la caméra de jeu
        m_activationButton.transform.LookAt(m_camera);
    }

    /// <summary>
    /// désactivation du script actuel
    /// </summary>
    public void PuzzleDeactivation()
    {
        m_openDoor = true;
        m_activationButton.SetActive(false);
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
            if (charaScript.m_chara == m_chara)
            {
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
        m_activationButton.SetActive(false);
        m_buttonActivate = false;
    }
    
    //if(delegator !=null) delegator();
    //delegator?.Invoke();
}
