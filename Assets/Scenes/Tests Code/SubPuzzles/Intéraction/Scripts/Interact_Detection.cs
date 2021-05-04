using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Interact_Detection : MonoBehaviour
{
    [HideInInspector] [SerializeField] [Tooltip("variable booléènne qui indique le passage entre puzzle et sub puzzle")] private bool m_isInSubPuzzle = false;
    [Tooltip("Bouton qui apparait afin de déclencher le puzzle")] public GameObject m_activationButton;
    
    [Tooltip("contrôle d'état du trigger du bouton permettant d'activer le sub puzzle")]
    public bool m_buttonActivate = false;
    
    
    [SerializeField] [Tooltip("personnage qui fait le subpuzzle")] private GameObject m_chara = null;

    [SerializeField] [Tooltip("camera à attacher au joueur pour le bouton d'activation au-dessus")] private Transform m_camera;
    
    [SerializeField] [Tooltip("boutons d'intéractions de la manette")] public SOInputMultiChara m_inputs = null;

    [SerializeField] [Tooltip("subpuzzle du monstre")] private GameObject m_puzzle;


    private void OnEnable()
    {
        m_isInSubPuzzle = true;
        //GameObject instantiatedPuzzle = Instantiate(m_puzzle,m_camera.transform.position, Quaternion.identity);
        m_puzzle.SetActive(true);
    }

    private void OnDisable()
    {
        m_isInSubPuzzle = false;
        m_puzzle.SetActive(false);
    }

    private void Update()
    {
        bool inputHuman = Input.GetKeyDown(m_inputs.inputHuman);
        bool inputMonster = Input.GetKeyDown(m_inputs.inputMonster);
        bool inputRobot = Input.GetKeyDown(m_inputs.inputRobot);

        //Input de l'humain et bouton visible ==> entrée dans subpuzzle
        if (inputHuman && m_buttonActivate)
        {
            m_isInSubPuzzle = true;
           GameObject instantiatedPuzzle = Instantiate(m_puzzle,m_camera.transform.position, Quaternion.identity);
        }
        else //Input du monstre et bouton visible ==> entrée dans subpuzzle
        if (inputMonster && m_buttonActivate)
        {
            m_isInSubPuzzle = true;
            GameObject instantiatedPuzzle = Instantiate(m_puzzle,m_camera.transform.position, Quaternion.identity);
        }
        else //Input du robot et bouton visible ==> entrée dans subpuzzle
        if (inputRobot && m_buttonActivate)
        {
            OnEnable();
        }
        
        //Le bouton d'activation regarde toujours en direction de la caméra de jeu
        m_activationButton.transform.LookAt(m_camera);
        
    }

    /// <summary>
    /// fonction de détection de collision entre le joueur et différents objets
    /// </summary>
    /// <param name="other"></param>
    private void OnTriggerEnter(Collider other)
    {
        //détection d'un objet de type sub puzzle
        if (other.gameObject == m_chara)
        {
            m_activationButton.SetActive(true);
            m_buttonActivate = true;
        }
    }
    
    /// <summary>
    /// Bouton d'activation de sub puzzle se désactive si le joueur est trop loin
    /// </summary>
    /// <param name="other"></param>
    private void OnTriggerExit(Collider other)
    {
        m_activationButton.SetActive(false);
        m_buttonActivate = false;
        
        if(m_isInSubPuzzle) OnDisable();  //destruction du puzzle si le joueur quitte la zone d'activation
    }
}
