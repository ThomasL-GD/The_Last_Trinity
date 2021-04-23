using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;
using Random = UnityEngine.Random;

public class MonsterPuzzle : MonoBehaviour
{
    [SerializeField] [Tooltip("Liste des pièces qui vont spawn")] private GameObject[] m_piecePrefab;
    
    //liste des pièces qui peuvent apparaitre
    [SerializeField] private List<GameObject> m_stockPieces = new List<GameObject>();
    //liste des pièces dans le jeu
    [SerializeField] private List<GameObject> m_potentialPieces = new List<GameObject>();
    //Liste des pièces correctes
    [SerializeField] private List<GameObject> m_correctPieces = new List<GameObject>();

    [SerializeField] [Tooltip("nombre de pièces présentes dans l'amalgame")] private int m_nbAmalgamePieces = 3;
    
    [SerializeField] [Tooltip("Décalage du prefab sur l'axe X")] private float m_offsetX = 4.0f;
    [SerializeField] [Tooltip("Décalage du prefab sur l'axe Y")] private float m_offsetY = 4.0f;
    
    [SerializeField] [Tooltip("Carré de selection qui se déplace entre les différentes instances de pièces présentes")] private Transform m_selector;

    // Variable d'index qui permet le déplacement du sélecteu
    private int m_index = 0;

    [Tooltip("Tableau à double entrée qui stocke les prefab")] public GameObject[,] m_prefabStock;
    
    [SerializeField] [Tooltip("hauteur du tableau de prefab")] private int m_arrayHeight = 10;
    [SerializeField] [Tooltip("largeur du tableau de prefab")] private int m_arrayWidth = 10;
    
    //Use for Debug only
    private GameObject m_prefabStockY=null;
    
    
    // Start is called before the first frame update
    void Start()
    {
        //Si nombre de pièces demandées à être affichées est inférieur au nombre de pièces possibles à afficher
        //si on veut afficher plus de pièces qu'on a, ça marche pas
        if (m_arrayHeight*m_arrayWidth > m_piecePrefab.Length)
        {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO MODIFY THE HEIGHT AND THE WIDTH OF THE ARRAY ACCORDING TO THE NUMBER OF DIFFERENT SYMBOLS !");
        }
        else PuzzlePiecesInstantiate();
        
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.LeftArrow))
        {
            m_selector.transform.position = m_piecePrefab[m_index--].transform.position;
            
            if (m_selector.transform.position == m_piecePrefab[0].transform.position)
            {
                m_selector.transform.position = m_piecePrefab[m_piecePrefab.Length].transform.position;
            }
        }
        
        else if (Input.GetKeyDown(KeyCode.RightArrow))
        {
            m_selector.transform.position = m_piecePrefab[m_index++].transform.position;
            
            if (m_selector.transform.position == m_piecePrefab[m_piecePrefab.Length].transform.position)
            {
                m_selector.transform.position = m_piecePrefab[0].transform.position;
            }
        }
    }


    private void PuzzlePiecesInstantiate()
    {
        //déplace toutes les prefab du tableau dans une liste
        for (int i = 0; i < m_piecePrefab.Length; i++)
        {
            m_stockPieces.Add(m_piecePrefab[i]);
        }
        
        //tableau à deux dimensions, placement des pièces
        m_prefabStock = new GameObject[m_arrayHeight, m_arrayWidth];
        
        //double boucle for pour créer le tableau
        for (int x = 0; x < m_arrayHeight; x++)
        {
            for (int y = 0; y < m_arrayWidth; y++)
            {
                int random = Random.Range(0, m_stockPieces.Count);
                
                transform.position = new Vector3(transform.position.x + m_offsetX,transform.position.y,0);

                m_prefabStock[x,y] = Instantiate(m_stockPieces[random], transform.position, transform.rotation);
                
                //déplace une prefab de la liste dans une seconde liste pout qu'elle ne puisse pas être invoquée deux fois d'affilée
                m_potentialPieces.Add(m_prefabStock[x,y]);
                m_stockPieces.RemoveAt(random);

            }
            //Retour à la ligne
            transform.position = new Vector3(transform.position.x - m_offsetX * m_arrayWidth,transform.position.y - m_offsetY,0);
        }
        

        //position de base du selecteur à l'ouverture du puzzle
        //Instantiate(m_selector, new Vector3(transform.position.x,transform.position.y, transform.position.z-1), Quaternion.identity);

        //Position du prefab à trouver parmi les prefab du tableau
        transform.position = new Vector3(transform.position.x + (((float)m_arrayWidth /2f) +0.5f)*m_offsetX, transform.position.y + (m_arrayHeight+2)*m_offsetY, 0);

        
        if (m_nbAmalgamePieces > m_correctPieces.Count)
        {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO MODIFY THE AMALGAM PIECES WICH IS TALLER THAN THE CORRECT PIECES !");
        }
        else for (int i = 0; i < m_nbAmalgamePieces; i++)
        {
            int random = Random.Range(0, m_potentialPieces.Count);
            
            Instantiate(m_potentialPieces[random], transform.position, transform.rotation);
            
            m_correctPieces.Add(m_potentialPieces[random]);
            m_potentialPieces.RemoveAt(random);
        }
        
        
    }

    
    
}
