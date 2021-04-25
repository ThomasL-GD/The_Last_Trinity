using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class MonsterPuzzle : MonoBehaviour
{
    [SerializeField] [Tooltip("Liste des pièces qui vont spawn")] private GameObject[] m_piecePrefab;
    
    //liste des pièces qui peuvent apparaitre
    [SerializeField] [Tooltip("Liste des pièces dans le stock")] private List<GameObject> m_stockPieces = new List<GameObject>();
    //liste des pièces dans la scène
    [SerializeField] [Tooltip("liste des pièces présentes dans la pièce")] private List<GameObject> m_potentialPieces = new List<GameObject>();
    //Liste des pièces correctes
    [SerializeField] [Tooltip("Liste des pièces à trouver parmi les pièces de la scène")] private List<GameObject> m_correctPieces = new List<GameObject>();

    
    [SerializeField] [Tooltip("nombre de pièces présentes dans l'amalgame")] private int m_nbAmalgamePieces = 3;
    
    [SerializeField] [Tooltip("Décalage du prefab sur l'axe X")] public float m_offsetX = 4.0f;
    [SerializeField] [Tooltip("Décalage du prefab sur l'axe Y")] public float m_offsetY = 4.0f;
    
    [SerializeField] [Tooltip("Carré de selection qui se déplace entre les différentes instances de pièces présentes")] private Transform m_selector;


    [Tooltip("Tableau à double entrée qui stocke les prefab")] public GameObject[,] m_prefabStock;
    [SerializeField] [Tooltip("hauteur du tableau de prefab")] private int m_arrayHeight = 10;
    [SerializeField] [Tooltip("largeur du tableau de prefab")] private int m_arrayWidth = 10;
    
    //Use for Debug only
    //private GameObject m_prefabStockY=null;
    
    [Tooltip("Tableau à double entrée qui stocke les positions des prefab")] public List<Vector3> m_piecesTransform = new List<Vector3>();



    // Start is called before the first frame update
    void Start()
    {
        //Si nombre de pièces demandées à être affichées est inférieur au nombre de pièces possibles à afficher
        if (m_arrayHeight*m_arrayWidth > m_piecePrefab.Length)
        {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO MODIFY THE HEIGHT AND THE WIDTH OF THE ARRAY ACCORDING TO THE NUMBER OF DIFFERENT SYMBOLS !");
        }
        else PuzzlePiecesInstantiate();
    }
    

    private void PuzzlePiecesInstantiate()
    {
        //déplace toutes les prefab du tableau dans une liste (list stockPieces)
        for (int i = 0; i < m_piecePrefab.Length; i++)
        {
            m_stockPieces.Add(m_piecePrefab[i]);
        }
        
        //tableau à deux dimensions qui place les pièces
        m_prefabStock = new GameObject[m_arrayHeight, m_arrayWidth];

        //tableau qui regroupe les positions des pièces dans la scène
        //m_piecesTransform = new Transform[Xposition,Yposition];
        
        //double boucle for pour créer le tableau
        for (int x = 0; x < m_arrayHeight; x++)
        {
            for (int y = 0; y < m_arrayWidth; y++)
            {
                //variable qui sort une position aléatoire dans la list de pièces du stock
                int random = Random.Range(0, m_stockPieces.Count);
                
                transform.position = new Vector3(transform.position.x + m_offsetX,transform.position.y,0);
                
                //instantiation dans la scène d'une pièce tirée dans le stock de prefab 
                m_prefabStock[x,y] = Instantiate(m_stockPieces[random], transform.position, transform.rotation);
                
                //ajout du prefab instancié dans une nouvelle liste regroupant les pièces actives
                //enlèvement du prefab instancié des prefab du stock pour ne pas avoir de pièces en double
                m_potentialPieces.Add(m_prefabStock[x,y]);
                m_stockPieces.RemoveAt(random);
                
                //ajout des positions des pièces dans un nouveau tableau
                m_piecesTransform.Add(transform.position);
                
            }
            //Retour à la ligne
            transform.position = new Vector3(transform.position.x - m_offsetX * m_arrayWidth,transform.position.y - m_offsetY,0);
        }
        
        
        
        //Position des prefab à trouver
        transform.position = new Vector3(transform.position.x + (((float)m_arrayWidth /2f) +0.5f)*m_offsetX, transform.position.y + (m_arrayHeight+1)*m_offsetY, transform.position.z);

        //création du selecteur dans la scène
        Instantiate(m_selector, new Vector3(m_piecesTransform[0].x, m_piecesTransform[0].y, transform.position.z), transform.rotation);
        
        //Instanciation des pièces à trouver parmi les pièces actives dans la scène
        //Si il y a plus de pièces à trouver que de pièces actives, erreur
        if (m_nbAmalgamePieces > m_potentialPieces.Count)
        {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO MODIFY THE AMALGAM PIECES WICH IS TALLER THAN THE CORRECT PIECES !");
        }
        else for (int i = 0; i < m_nbAmalgamePieces; i++)
        {
            //variable qui recherche un préfab aléatoirement dans la liste des pièces présentes dans la scène (potentialPieces)
            int random = Random.Range(0, m_potentialPieces.Count);
            
            //ajout du prefab à l'emplacement des prefab à trouver
            Instantiate(m_potentialPieces[random], transform.position, transform.rotation);
            
            //ajout du préfab présent dans la scène à la liste de prefab à trouver (correctPieces)
            //enlèvement de ce prefab de la liste des prefab à instancier dans la scène pour éviter de devoir trouver deux fois le même
            m_correctPieces.Add(m_potentialPieces[random]);
            m_potentialPieces.RemoveAt(random);
        }
    }
    
    
    
}
