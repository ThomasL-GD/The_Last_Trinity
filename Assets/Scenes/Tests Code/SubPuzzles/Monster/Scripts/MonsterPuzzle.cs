using System;
using System.Collections.Generic;
using System.Net.NetworkInformation;
using UnityEngine;
using Random = UnityEngine.Random;

public class MonsterPuzzle : MonoBehaviour
{
    [SerializeField] [Tooltip("Liste des pièces qui vont spawn")] private GameObject[] m_piecePrefab;
    
    [Header("Listes")]
    [Tooltip("liste des pièces qui peuvent apparaitre")]private List<GameObject> m_stockPieces = new List<GameObject>();
    [Tooltip("liste des pièces dans la scène")] private List<GameObject> m_potentialPieces = new List<GameObject>();
    [Tooltip("liste des pièces correctes")] private List<GameObject> m_correctPieces = new List<GameObject>();
    [Tooltip("List des pièces trouvées")] private List<GameObject> m_foundPieces = new List<GameObject>();

    [Header("Décalage")]
    [SerializeField] [Tooltip("Décalage du prefab sur l'axe X")] private float m_offsetX = 4.0f;
    [SerializeField] [Tooltip("Décalage du prefab sur l'axe Y")] private float m_offsetY = 4.0f;

    [SerializeField] [Tooltip("The shift of height attributed to the jumble")] [Range(0.8f, 3f)] private float m_jumbleShift = 1f;
    
    
    //Tableau à double entrée qui stocke les prefab
    private GameObject[,] m_prefabStock;
    [Header("Dimensions")]
    [SerializeField] [Tooltip("hauteur du tableau de prefab")] public int m_arrayHeight = 10;
    [SerializeField] [Tooltip("largeur du tableau de prefab")] public int m_arrayWidth = 10;

    [SerializeField] [Tooltip("Carré de selection qui se déplace entre les différentes instances de pièces présentes")] private GameObject m_prefabSelector = null;

    //La position de la première case
    private Vector3 m_initialPos = Vector3.zero;
    //transform du sélecteur
    private Transform m_selectorTransform = null;
    //Coordonnées du sélecteur
    private int m_selectorX = 0;
    private int m_selectorY = 0;
    
    [Header("Valeurs en jeu")]
    [SerializeField] [Tooltip("nombre de pièces présentes dans l'amalgame")] [Range(2, 15)] public int m_nbAmalgamePieces = 3;
    [Tooltip("compte de pièce à trouver")] private int m_findPiece = 0;
    [SerializeField] private int m_errorAllowed = 3;  //nombre d'essais possibles avant echec de subpuzzle
    [HideInInspector] [Tooltip("validation de puzzle")] public bool m_achieved = false;

    [Header("Joystick Manager")]
    [Tooltip("position limite de joystick")] private float m_limitPosition = 0.5f;
    [HideInInspector] [Tooltip("variable de déplacement en points par points du sélecteur")] private bool m_hasMoved = false;
    [SerializeField] public SOInputMultiChara m_inputs = null;

    [HideInInspector] [Tooltip("Script d'intéraction entre le personnage et l'objet comprenant le subpuzzle")] public Interact_Detection m_interactDetection = null;
    
    // Start is called before the first frame update
    void Start()
    {
        //Si nombre de pièces demandées à être affichées est inférieur au nombre de pièces possibles à afficher
        if (m_arrayHeight*m_arrayWidth > m_piecePrefab.Length)
        {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO MODIFY THE HEIGHT AND THE WIDTH OF THE ARRAY ACCORDING TO THE NUMBER OF DIFFERENT SYMBOLS !");
        }
        else PuzzlePiecesInstantiate();

        if(m_prefabSelector == null) Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO PUT THE PREFAB OF THE SELECTOR !");
        
    }
    

    /// <summary>
    /// Fonction de création du puzzle dans la scène
    /// 1 - ajout de tous les préfab du tableau de base dans une liste
    /// 2 - création du tableau à deux dimensions dans la scène avec les prefab de la liste
    /// 3 - création du sélecteur dans la scène et positionnnement de celle-ci
    /// 4 - ajout des pièces correctes à dénicher parmi les pièces présentes dans la scène à une nouvelle liste de pièces correctes
    /// </summary>
    private void PuzzlePiecesInstantiate()
    {
        //déplace toutes les prefab du tableau dans une liste (list stockPieces)
        for (int i = 0; i < m_piecePrefab.Length; i++)
        {
            m_stockPieces.Add(m_piecePrefab[i]);
        }
        
        //Fonction qui va instancier les pièces aléatoirement dans la scène
        PuzzleStructure();

        //création du selecteur dans la scène
        GameObject instance = Instantiate(m_prefabSelector, m_initialPos, transform.rotation);
        
        //transform du sélecteur récupéré à l'instanciation
        m_selectorTransform = instance.transform;
        
        //Position des prefab à trouver
        transform.position = new Vector3(transform.position.x + (((float)m_arrayWidth /2f) +0.5f)*m_offsetX, transform.position.y + m_offsetY*m_arrayHeight + (m_offsetY*m_jumbleShift), transform.position.z);
        
        //Fonction des pièces à trouver parmi les pièces présentes
        CorrectPiecesInstantiate();
        
    }

    /// <summary>
    /// Fonction de création des dimensions du tableau dans la scène et des places des prefab de pièce
    /// On ajoute une pièce de la liste des pièces du stock à la liste des pièces dans la scène
    /// On l'enlève ensuite du stock pour ne pas avoir deux fois la même pièce dans la scène
    /// On récupère la position de la première pièce instanciée pour positionner ensuite notre sélecteur
    /// </summary>
    private void PuzzleStructure()
    {
        //tableau à deux dimensions qui place les pièces
        m_prefabStock = new GameObject[m_arrayHeight, m_arrayWidth];

        GameObject emptyContainer = new GameObject("PiecesContainer");
        GameObject container = Instantiate(emptyContainer);

        //double boucle for pour créer le tableau
        for (int x = 0; x < m_arrayHeight; x++)
        {
            for (int y = 0; y < m_arrayWidth; y++)
            {
                //variable qui sort une position aléatoire dans la list de pièces du stock
                int random = Random.Range(0, m_stockPieces.Count);
                
                //décalage de la position en x avant instance du prefab
                transform.position = new Vector3(transform.position.x + m_offsetX,transform.position.y,0);
                
                //instantiation dans la scène d'une pièce tirée dans le stock de prefab 
                m_prefabStock[x,y] = Instantiate(m_stockPieces[random], transform.position, transform.rotation,container.transform);
                
                //ajout du prefab instancié dans une nouvelle liste regroupant les pièces actives
                //enlèvement du prefab instancié des prefab du stock pour ne pas avoir de pièces en double
                m_potentialPieces.Add(m_prefabStock[x,y]);
                m_stockPieces.RemoveAt(random);

                //récupération de la position de la première prefab instanciée
                //position sert à placer le sélecteur qui reprend m_initialPos
                if (x == 0 && y == 0) m_initialPos = transform.position;
            }
            //Retour à la ligne
            transform.position = new Vector3(transform.position.x - m_offsetX * m_arrayWidth,transform.position.y - m_offsetY,0);
        }
    }
    
    /// <summary>
    /// Ajout d'une pièce aléatoire dans la scène à la liste des pièces à trouver
    /// On enlève ensuite cette pièce des pièces de la scène pour ne pas à avoir trouver deux fois la même
    /// </summary>
    private void CorrectPiecesInstantiate()
    {
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
    
    
    /// <summary>
    /// Déplacement du sélecteur par à coups avec différents inputs
    /// 
    /// Input de sélection de pièce :
    ///  1 - vérification si la pièce sur laquelle le sélecteur se situe est correcte
    ///  2 - Si elle est correcte, on vérifie qu'elle n'a pas déjà été ajouté
    ///  3 - Si elle n'a pas été ajouté, on l'ajoute
    ///  4 - Si elle a été ajouté, rien ne se passe
    ///  5 - Si elle n'est pas correcte, le nombre d'erreurs possibles à faire diminue
    /// </summary>
    void Update()
    {
        float horizontalAxis = Input.GetAxis("Horizontal");
        float verticalAxis = Input.GetAxis("Vertical");
        bool selectorValidation = Input.GetKeyDown(m_inputs.inputMonster);
        

        if (!m_hasMoved && horizontalAxis < -m_limitPosition || horizontalAxis > m_limitPosition || verticalAxis >m_limitPosition || verticalAxis < -m_limitPosition) {
            
            //déplacement du sélecteur avec le joystick gauche
            if (!m_hasMoved && horizontalAxis < -m_limitPosition && m_selectorX > 0)   //Déplacement a gauche si position X sélecteur > position  X  première prefab instanciée
            {
                m_selectorX--;
                m_hasMoved = true;
            }
            else if (!m_hasMoved && horizontalAxis > m_limitPosition && m_selectorX < m_arrayWidth-1)  //Déplacement à droite si position  X sélecteur  < valeur largeur tableau prefab
            {
                m_selectorX++;
                m_hasMoved = true;
            }
            else if (!m_hasMoved && verticalAxis >m_limitPosition && m_selectorY > 0)  //Déplacement en haut si position Y sélecteur < position Y première prefab
            {
                m_selectorY--;
                m_hasMoved = true;
            }
            else if (!m_hasMoved && verticalAxis < -m_limitPosition && m_selectorY < m_arrayHeight-1) //Déplacement en bas si position Y sélecteur > valeur dernière prefab du tableau prefab
            {
                m_selectorY++;
                m_hasMoved = true;
            }

            //nouvelle position du sélecteur
            m_selectorTransform.position = new Vector3(m_initialPos.x + m_selectorX * m_offsetX, m_initialPos.y - m_selectorY * m_offsetY, m_initialPos.z);
        }

        //Joystick se recentre sur la manette
        if (horizontalAxis < m_limitPosition && horizontalAxis > -m_limitPosition && verticalAxis < m_limitPosition && verticalAxis > -m_limitPosition)
        {
            m_hasMoved = false;
        }
        
        
        if (selectorValidation) //input monster
        {
            bool isCorrectPiece = false;    //variable booléènne qui indique si le joueur est sur une bonne pièce ou non
            bool isAlreadyFound = false;    //Variable booléènne qui indique si la pièce a déjà été trouvée
            
            for (int i = 0; i < m_correctPieces.Count; i++) //pour chaque pièce dans les pièces correctes
            {
                if (m_prefabStock[m_selectorY, m_selectorX] == m_correctPieces[i]) //si le sélecteur est à la même position que la pièce actuelle de correct pieces
                {
                    for (int j = 0; j < m_foundPieces.Count; j++)   //Pour chaque pièces dans les pièces trouvées
                    {
                        if (m_prefabStock[m_selectorY, m_selectorX] == m_foundPieces[j])    //Si le sélecteur est à la même position que la pièce actuelle dans foundPiece
                        {
                            isAlreadyFound = true;  //la pièce en question a déjà été trouvé
                            Debug.Log("Vous avez déjà trouvé sur cette pièce");
                            j = m_foundPieces.Count;
                        }
                    }

                    if (!isAlreadyFound)    //Si la pièce n'a pas encore été trouvée
                    {
                        m_foundPieces.Add(m_correctPieces[i]); //ajout d'une pièce correcte à pièce trouvé
                        
                        isCorrectPiece = true; //indique qu'une pièce est bonne
                        m_findPiece++; //incrémentation des bonnes pièces trouvées

                        if (m_findPiece == m_nbAmalgamePieces) //Si le nombre de pièces trouvées = nombre de pièces à trouver
                        {
                            Debug.Log("Vous avez trouvé toutes les pièces !");
                            m_achieved = true;  //le joueur a trouvé toutes les pièces
                        }

                        m_prefabStock[m_selectorY, m_selectorX].SetActive(false);   //feedback disparition

                        i = m_correctPieces.Count; //Arrête la boucle for dès trouvaille de pièce correcte
                    }
                }

            }

            if(isCorrectPiece == false && isAlreadyFound == false) //compteur de défaite s'incrémente de 1
            {
                m_errorAllowed--;   //nombre d'erreurs possibles avant défaite diminue
                if (m_errorAllowed == 0)
                {
                    OnDisable();
                    Debug.Log("Vous avez perdu.");
                }
            }

            selectorValidation = false;
        }
    }
    
    
    /// <summary>
    /// Is called when this gameObject is setActive(false)
    /// Is used to destroy everything it created
    /// </summary>
    void OnDisable()
    {
        m_interactDetection.PuzzleDeactivation();
        
        // https://memegenerator.net/instance/44816816/plotracoon-we-shall-destroy-them-all
        //As all the gameobjects we instantiated are child of this gameobject, we just have to erase all the children of this
        foreach(Transform child in gameObject.transform) {
            Destroy(child.gameObject);
        }
        
    }
    
    
}
