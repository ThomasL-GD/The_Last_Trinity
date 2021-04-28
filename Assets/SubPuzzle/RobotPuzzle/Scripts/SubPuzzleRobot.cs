using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class SubPuzzleRobot : MonoBehaviour
{
    public class Selector
    {
        //coordonnées du sélecteur
        public int x = 0;
        public int y = 0;
    }

    private Selector m_selector = new Selector();
    
    [SerializeField] [Tooltip("Liste des pièces de notre bibliothèque")] private GameObject[] m_piecePrefab;

    //liste des pièces qui peuvent apparaitre dans le jeu
    [SerializeField] [Tooltip("Liste des pièces dans le stock")] private List<GameObject> m_stockPieces = new List<GameObject>();
    //liste des pièces dans la scène
    [SerializeField] [Tooltip("liste des pièces présentes dans la scène")] private List<GameObject> m_scenePieces = new List<GameObject>();
    
    [SerializeField] [Tooltip("Décalage du prefab sur l'axe X")] private float m_offsetX = 4.0f;
    [SerializeField] [Tooltip("Décalage du prefab sur l'axe Y")] private float m_offsetY = 4.0f;

    //Tableau à double entrée qui stocke les prefab
    private GameObject[,] m_prefabStock;
    
    [SerializeField] [Tooltip("hauteur du tableau de prefab")] public int m_arrayHeight = 10;
    [SerializeField] [Tooltip("largeur du tableau de prefab")] public int m_arrayWidth = 10;

    [SerializeField] [Tooltip("Carré de selection qui se déplace entre les différentes instances de pièces présentes")] private GameObject m_prefabSelector = null;

    //La position de la première case
    private Vector3 m_initialPos = Vector3.zero;

    //transform du sélecteur
    private Transform m_selectorTransform = null;
    

    //valeur de rotation d'une pièce
    private float m_pieceRotation = 90;

    private movePiece m_movePiece;
    
    // Start is called before the first frame update
    void Start()
    {
        PuzzlePiecesInstantiate();

        if (m_prefabSelector == null)
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO PUT THE PREFAB OF THE SELECTOR !");

    }

    void PuzzlePiecesInstantiate()
    {
        //déplace toutes les prefab du tableau dans une liste (list stockPieces)
        for (int i = 0; i < m_piecePrefab.Length; i++)
        {
            m_stockPieces.Add(m_piecePrefab[i]);
        }
        
        PuzzleStructure();

        //création du selecteur dans la scène
        GameObject instance = Instantiate(m_prefabSelector, m_initialPos, transform.rotation);

        //le sélecteur se positionne  à la position
        m_selectorTransform = instance.transform;
    }

    private void PuzzleStructure()
    {
        //tableau à deux dimensions qui place les pièces
        m_prefabStock = new GameObject[m_arrayHeight, m_arrayWidth];

        //double boucle for pour créer le tableau
        for (int x = 0; x < m_arrayHeight; x++)
        {
            for (int y = 0; y < m_arrayWidth; y++)
            {
                //variable qui sort une position aléatoire dans la list de pièces du stock
                int random = Random.Range(0, m_stockPieces.Count);

                //décalage de la position en x avant instance du prefab
                transform.position = new Vector3(transform.position.x + m_offsetX, transform.position.y, 0);

                //instantiation dans la scène d'une pièce tirée dans le stock de prefab 
                m_prefabStock[x, y] = Instantiate(m_stockPieces[random], transform.position, transform.rotation);

                //ajout des pièces à la liste de pièces présentes dans la scène
                m_scenePieces.Add(m_prefabStock[x,y]);
                
                //récupération de la position de la première prefab instanciée
                //position sert à placer le sélecteur qui reprend m_initialPos
                if (x == 0 && y == 0) m_initialPos = transform.position;
            }

            //Retour à la ligne
            transform.position = new Vector3(transform.position.x - m_offsetX * m_arrayWidth, transform.position.y - m_offsetY, 0);
        }
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.LeftArrow) || Input.GetKeyDown(KeyCode.RightArrow) ||
            Input.GetKeyDown(KeyCode.UpArrow) || Input.GetKeyDown(KeyCode.DownArrow))
        {

            //déplacement du sélecteur
            if (Input.GetKeyDown(KeyCode.LeftArrow) && m_selector.x > 0) //Déplacement a gauche si position X sélecteur > position  X  première prefab instanciée
            {
                m_selector.x--;
            }
            else if (Input.GetKeyDown(KeyCode.RightArrow) && m_selector.x < m_arrayWidth - 1) //Déplacement à droite si position  X sélecteur  < valeur largeur tableau prefab        // -1 parce que départ de 0
            {
                m_selector.x++;
            }
            else if (Input.GetKeyDown(KeyCode.UpArrow) && m_selector.y > 0) //Déplacement en haut si position Y sélecteur < position Y première prefab
            {
                m_selector.y--;
            }
            else if (Input.GetKeyDown(KeyCode.DownArrow) && m_selector.y < m_arrayHeight - 1) //Déplacement en bas si position Y sélecteur > valeur dernière prefab du tableau prefab       // -1 parce que départ de 0
            {
                m_selector.y++;
            }

            m_selectorTransform.position = new Vector3(m_initialPos.x + m_selector.x * m_offsetX, m_initialPos.y - m_selector.y * m_offsetY, m_initialPos.z);
        }

        if (Input.GetKeyDown(KeyCode.Space))
        {
            for (int i = 0; i < m_scenePieces.Count; i++) //pour chaque pièce présente dans la scène
            {
                if (m_prefabStock[m_selector.y, m_selector.x] == m_scenePieces[i]) //si le sélecteur est à la même position que la pièce actuelle de scenePieces
                {
                    m_scenePieces[i].transform.Rotate(Vector3.back, m_pieceRotation);   //rotation de la pièce sur laquelle le sélecteur se situe
                }

            }
        }
        
    }






}
