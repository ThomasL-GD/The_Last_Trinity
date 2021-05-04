using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Interact_Detection : MonoBehaviour
{
    [SerializeField] [Tooltip("variable booléènne qui indique le passage entre puzzle et sub puzzle")]
    private bool m_isInSubPuzzle = false;
    
    [Tooltip("Bouton qui apparait afin de déclencher le puzzle")]
    public GameObject m_activationButton;
    
    [Tooltip("contrôle d'état du trigger du bouton permettant d'activer le sub puzzle")]
    public bool m_buttonActivate = false;

    [SerializeField] [Tooltip("personnage qui fait le subpuzzle")] private GameObject m_chara = null;

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
}
