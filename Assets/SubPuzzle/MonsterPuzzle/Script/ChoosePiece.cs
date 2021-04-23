using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;


public class ChoosePiece : MonoBehaviour
{

    /// <summary>
    /// variable de position de pièce de puzzle
    /// </summary>
    public int m_position;

    /// <summary>
    /// script de la génération des pièces
    /// </summary>
    private MonsterPuzzle m_monsterPuzzle;

    private void Start()
    {
        m_monsterPuzzle = GameObject.Find("MonsterPuzzle").GetComponent<MonsterPuzzle>();
    }

    /*
    /// <summary>
    /// Fonction qui démarre en cas d'input de la souris sur un gameobject uqi a un collider
    /// </summary>
    private void OnMouseDown()
    {
        if (this.m_position == m_monsterPuzzle.m_randomPiece)
        {
            Debug.Log("Trouvé");
        }
        else
        {
            Debug.Log("Perdu");
        }
    }
    */
    
}
