using UnityEngine;
using System.Collections.Generic;

public class ChoosePiece : MonoBehaviour
{
    /// <summary>
    /// script de la génération des pièces
    /// </summary>
    private MonsterPuzzle m_monsterPuzzle;

    public Transform[] m_piecePosition;

    private void Start()
    {
        m_monsterPuzzle = GameObject.Find("MonsterPuzzle").GetComponent<MonsterPuzzle>();
        
        //m_monsterPuzzle.m_piecesTransform.AddRange(m_piecePosition);
        
        //m_monsterPuzzle.m_piecesTransform.Add();
    }

    
    /// <summary>
    /// Fonction qui démarre en cas d'input de la souris sur un gameobject uqi a un collider
    /// </summary>
    private void OnMouseDown()
    {
        if (this == null)
        {
            Debug.Log("Trouvé");
        }
        else
        {
            Debug.Log("Perdu");
        }
    }

    
    
    
}
