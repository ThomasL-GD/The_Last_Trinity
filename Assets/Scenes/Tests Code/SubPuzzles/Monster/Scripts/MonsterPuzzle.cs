using System;
using System.Collections;
using System.Collections.Generic;
using System.Net.NetworkInformation;
using UnityEditor.VersionControl;
using UnityEngine;
using UnityEngine.Serialization;
using Random = UnityEngine.Random;
using UnityEngine.InputSystem;
using System.Linq;
using UnityEngine.InputSystem.Controls;

public class MonsterPuzzle : MonoBehaviour
{
    [Header("Prefabs")]
    [SerializeField] [Tooltip("Liste des pièces qui vont spawn")] private GameObject[] m_piecePrefab;
    [SerializeField] [Tooltip("Carré de selection qui se déplace entre les différentes instances de pièces présentes")] private GameObject m_prefabSelector = null;
    
    [Header("Listes")]
    [Tooltip("liste des pièces qui peuvent apparaitre")]private List<GameObject> m_stockPieces = new List<GameObject>();
    [SerializeField] [Tooltip("liste des pièces dans la scène")] private List<GameObject> m_potentialPieces = new List<GameObject>();
    [SerializeField] [Tooltip("liste des pièces correctes")] private List<GameObject> m_correctPieces = new List<GameObject>();
    [SerializeField] [Tooltip("liste des pièces Incorrectes")] private List<GameObject> m_incorrectPieces = new List<GameObject>();
    [SerializeField] [Tooltip("List des pièces trouvées")] private List<GameObject> m_foundPieces = new List<GameObject>();

    //Décalage
    [Tooltip("FOR DEBUG ONLY\nSize of each cell in Rect Transorm anchor units")] private float m_offset = 4.0f;
    [Tooltip("FOR DEBUG ONLY\nThe shift every cell does in order to be perfectly centered on the screen")] private float m_centerShift = 0.0f;
    
    
    //Tableau à double entrée qui stocke les prefab
    private GameObject[,] m_prefabStock;
    [Header("Dimensions")]
    [SerializeField] [Tooltip("hauteur du tableau de prefab")] [Range(0,20)] public int m_arrayHeight = 10;
    [SerializeField] [Tooltip("largeur du tableau de prefab")] [Range(0,20)] public int m_arrayWidth = 10;

    //La position de la première case
    private Vector3 m_initialPos = Vector3.zero;
    //transform du sélecteur
    private Transform m_selectorTransform = null;
    //Coordonnées du sélecteur
    private int m_selectorX = 0;
    private int m_selectorY = 0;
    
    [Header("Gestion Difficulté")]
    [SerializeField] [Tooltip("nombre de pièces présentes dans l'amalgame")] [Range(2, 15)] public int m_nbAmalgamePieces = 3;
    [Tooltip("compte de pièce à trouver")] private int m_findPiece = 0;
    [SerializeField] [Tooltip("The number of errors the player is allowed to make before being kicked out of the sub puzzle")] [Range(0, 10)] public int m_errorAllowed = 3;  //nombre d'essais possibles avant echec de subpuzzle
    private int m_errorDone = 0; //reset du nombre d'erreurs possibles

    [Header("Joystick Manager")]
    [SerializeField] public SOInputMultiChara m_inputs = null;
    [Tooltip("position limite de joystick")] private float m_limitPosition = 0.5f;
    [HideInInspector] [Tooltip("variable de déplacement en points par points du sélecteur")] private bool m_hasMoved = false;

    [Header("Rumble")]
    [SerializeField] [Range(0f,10f)] private float m_rumbleDuration = 0f;
    [SerializeField] [Range(0f,1f)] private float m_lowA =0f;
    [SerializeField] [Range(0f,1f)] private float m_highA =0f;
    private PlayerInput m_playerInput;
    Gamepad m_gamepad = Gamepad.current;
    
    [HideInInspector] [Tooltip("Script d'intéraction entre le personnage et l'objet comprenant le subpuzzle")] public Interact_Detection m_interactDetection = null;
    

    
    // OnEnable is called before the first frame update
    void OnEnable() {
        m_interactDetection.SquarePanelToScreen();
        
        //We calculate the size of each cell
        m_offset = 0f;
        m_centerShift = 0.0f;
        if (m_arrayWidth >= m_arrayHeight + 2) {
            m_offset = (1f/m_arrayWidth);
        }
        else {
            m_offset = (1f / (m_arrayHeight + 2));
            m_centerShift = 0.5f * ((m_arrayHeight + 2) - m_arrayWidth);
        }
        
        //Si nombre de pièces demandées à être affichées est inférieur au nombre de pièces possibles à afficher
        if (m_arrayHeight*m_arrayWidth > m_piecePrefab.Length)
        {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO MODIFY THE HEIGHT AND THE WIDTH OF THE ARRAY ACCORDING TO THE NUMBER OF DIFFERENT SYMBOLS !");
        }
        else PuzzleGenerate();

        if(m_prefabSelector == null) Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO PUT THE PREFAB OF THE SELECTOR !");

        RectTransform rect = gameObject.GetComponent<RectTransform>();
        rect.localPosition = Vector3.zero;
        rect.anchoredPosition = Vector2.zero;
        
        m_playerInput = GetComponent<PlayerInput>();
        m_gamepad = GetGamepad();
    }
    

    
    /// <summary>
    /// CREATION DES PIECES A CHERCHER, DU SELECTEUR ET DES PIECES A TROUVER
    ///
    /// 1 - Déplacement des prefab d'un tableau vers une liste (stock)
    /// 2 - Création des dimensions du tableau dans la scène et des places des prefab de pièce
    /// 3 - On ajoute une pièce du stock à la scène
    /// 4 - On l'enlève ensuite du stock pour ne pas avoir deux fois la même pièce dans la scène
    /// 5 - On récupère la position de la première pièce instanciée pour positionner ensuite notre sélecteur
    /// 6 - On instancie ensuite une pièce de la scène dans les pièces correctes
    /// </summary>
    private void PuzzleGenerate()
    {
        //déplace toutes les prefab du tableau dans une liste (list stockPieces)
        for (int i = 0; i < m_piecePrefab.Length; i++)
        {
            m_stockPieces.Add(m_piecePrefab[i]);
        }
        
        //tableau à deux dimensions qui place les pièces
        m_prefabStock = new GameObject[m_arrayHeight, m_arrayWidth];
        
        
        /////////////////////////////////////////////////////////////////////////////   RANDOM PIECES   /////////////////////////////////////////////////////////////////////////////

        
        //double boucle for pour créer le tableau
        for (int x = 0; x < m_arrayHeight; x++)
        {
            for (int y = 0; y < m_arrayWidth; y++)
            {
                //variable qui sort une position aléatoire dans la list de pièces du stock
                int random = Random.Range(0, m_stockPieces.Count);
                
                //instantiation dans la scène d'une pièce tirée dans le stock de prefab 
                m_prefabStock[x,y] = Instantiate(m_stockPieces[random], transform.position, transform.rotation, gameObject.transform);
                SetRectPosition(m_prefabStock[x,y], y, x);
                
                //ajout du prefab instancié dans une nouvelle liste regroupant les pièces actives
                //enlèvement du prefab instancié des prefab du stock pour ne pas avoir de pièces en double
                m_potentialPieces.Add(m_prefabStock[x,y]);
                m_stockPieces.RemoveAt(random);

                //récupération de la position de la première prefab instanciée
                if (x == 0 && y == 0) m_initialPos = transform.position;
            }
        }
        
        
        /////////////////////////////////////////////////////////////////////////////   SELECTEUR   /////////////////////////////////////////////////////////////////////////////
        
        
        //création du selecteur dans la scène
        GameObject instance = Instantiate(m_prefabSelector, m_initialPos, transform.rotation, gameObject.transform);
        SetRectPosition(instance, 0, 0);
        
        //transform du sélecteur récupéré à l'instanciation
        m_selectorTransform = instance.transform;


        /////////////////////////////////////////////////////////////////////////////   CORRECT PIECES   /////////////////////////////////////////////////////////////////////////////

        
        //Instanciation des pièces à trouver parmi les pièces actives dans la scène
        //Si il y a plus de pièces à trouver que de pièces actives, erreur
        if (m_nbAmalgamePieces > m_potentialPieces.Count)
        {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO MODIFY THE AMALGAM PIECES WHICH IS TALLER THAN THE CORRECT PIECES !");
        }
        else for (int i = 0; i < m_nbAmalgamePieces; i++)
        {
                //variable qui recherche un préfab aléatoirement dans la liste des pièces présentes dans la scène (potentialPieces)
                int random = Random.Range(0, m_potentialPieces.Count);

                //ajout du prefab à l'emplacement des prefab à trouver
                GameObject gameO = Instantiate(m_potentialPieces[random], transform.position, transform.rotation, gameObject.transform);
                SetRectPosition(gameO, (((float)m_arrayWidth)/2f) - 0.5f, m_arrayHeight + 1);

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
        bool canSelect = true;

        if (!m_hasMoved && horizontalAxis < -m_limitPosition || horizontalAxis > m_limitPosition || verticalAxis >m_limitPosition || verticalAxis < -m_limitPosition) {
            
            //déplacement du sélecteur avec le joystick gauche
            if (m_interactDetection.m_canMove && !m_hasMoved && horizontalAxis < -m_limitPosition && m_selectorX > 0)   //Déplacement a gauche si position X sélecteur > position  X  première prefab instanciée
            {
                m_selectorX--;
                m_hasMoved = true;
            }
            else if (m_interactDetection.m_canMove && !m_hasMoved && horizontalAxis > m_limitPosition && m_selectorX < m_arrayWidth-1)  //Déplacement à droite si position  X sélecteur  < valeur largeur tableau prefab
            {
                m_selectorX++;
                m_hasMoved = true;
            }
            else if (m_interactDetection.m_canMove && !m_hasMoved && verticalAxis > m_limitPosition && m_selectorY < m_arrayHeight-1)  //Déplacement en haut si position Y sélecteur < position Y première prefab
            {
                m_selectorY++;
                m_hasMoved = true;
            }
            else if (m_interactDetection.m_canMove && !m_hasMoved && verticalAxis < -m_limitPosition && m_selectorY > 0) //Déplacement en bas si position Y sélecteur > valeur dernière prefab du tableau prefab
            {
                m_selectorY--;
                m_hasMoved = true;
            }

            //nouvelle position du sélecteur
            SetRectPosition(m_selectorTransform.gameObject, m_selectorX, m_selectorY);
        }

        //Joystick se recentre sur la manette
        if (horizontalAxis < m_limitPosition && horizontalAxis > -m_limitPosition && verticalAxis < m_limitPosition && verticalAxis > -m_limitPosition)
        {
            m_hasMoved = false;
        }
        

        if (selectorValidation) //input monster
        {
            
            bool isCorrectPiece = false;    //variable booléènne qui indique si le joueur est sur une bonne pièce
            bool isAlreadyFound = false;    //Variable booléènne qui indique si la pièce a déjà été trouvée
            
            /////////////// VERIFICATION SI C'EST UNE PIECE CORRECTE /////////////
            for (int i = 0; i < m_correctPieces.Count; i++) //pour chaque pièce dans les pièces correctes
            {
                if (m_prefabStock[m_selectorY, m_selectorX] == m_correctPieces[i]) //si le sélecteur est à la même position que la pièce actuelle de correct pieces
                {
                    for (int j = 0; j < m_foundPieces.Count; j++)   //Pour chaque pièces dans les pièces trouvées
                    {
                        if (m_prefabStock[m_selectorY, m_selectorX] == m_foundPieces[j])    //Si le sélecteur est à la même position que la pièce actuelle dans foundPiece
                        {
                            isAlreadyFound = true;  //la pièce en question a déjà été trouvé
                            j = m_foundPieces.Count;
                        }
                    }

                    //PIECE PAS ENCORE TROUVEE ET CORRECTE
                    if (!isAlreadyFound)    
                    {
                        m_foundPieces.Add(m_correctPieces[i]); //ajout d'une pièce correcte à pièce trouvé
                        
                        isCorrectPiece = true; //indique qu'une pièce est bonne
                        m_findPiece++; //incrémentation des bonnes pièces trouvées

                        if (m_findPiece == m_nbAmalgamePieces) //Si le nombre de pièces trouvées = nombre de pièces à trouver
                        {
                            Debug.Log("Vous avez trouvé toutes les pièces !");

                            m_interactDetection.m_achieved = true;  //le joueur a trouvé toutes les pièces
                            m_interactDetection.m_canMove = false;  //le joueur ne peut plus bouger le selecteur
                            if(m_interactDetection.enabled)m_interactDetection.PuzzleDeactivation();
                        }

                        Instantiate(m_selectorTransform, m_prefabStock[m_selectorY, m_selectorX].transform.position, m_prefabStock[m_selectorY, m_selectorX].transform.rotation, gameObject.transform);  //feedback de trouvage de pièce
                        
                        i = m_correctPieces.Count; //Arrête la boucle for dès trouvaille de pièce correcte
                    }
                }
            }
            
            /////////////// VERIFICATION SI C'EST UNE PIECE CORRECTE /////////////
            for (int i = 0; i < m_potentialPieces.Count; i++) //pour chaque pièce dans les pièces correctes
            {
                if (m_prefabStock[m_selectorY, m_selectorX] == m_potentialPieces[i]) //si le sélecteur est à la même position que la pièce actuelle de correct pieces
                {
                    for (int j = 0; j < m_incorrectPieces.Count; j++)   //Pour chaque pièces dans les pièces trouvées
                    {
                        if (m_prefabStock[m_selectorY, m_selectorX] == m_incorrectPieces[j])    //Si le sélecteur est à la même position que la pièce actuelle dans foundPiece
                        {
                            isAlreadyFound = true;  //la pièce en question a déjà été trouvé
                            j = m_foundPieces.Count;
                        }
                    }

                    //PIECE PAS ENCORE TROUVEE ET INCORRECTE
                    if (!isAlreadyFound)    
                    {
                        m_incorrectPieces.Add(m_potentialPieces[i]); //ajout d'une pièce incorrecte aux pièces incorrectes
                        
                        isCorrectPiece = false; //indique qu'une pièce est incorrecte
                        
                        m_prefabStock[m_selectorY, m_selectorX].SetActive(false);   //désactive la pièce
                        
                        i = m_potentialPieces.Count; //Arrête la boucle for dès trouvaille de pièce incorrecte
                    }
                }
            }
            
            if(isCorrectPiece == false && isAlreadyFound == false) //compteur de défaite s'incrémente de 1
            {
                m_errorDone++;   //nombre d'erreurs possibles avant défaite diminue

                if(m_errorDone != m_errorAllowed) StartCoroutine("Rumble");   //Vibration
                else if (m_errorDone == m_errorAllowed)
                {
                    if(m_interactDetection.enabled)m_interactDetection.PuzzleDeactivation();
                }
            }
            selectorValidation = false;
        }
        

        //Sortie du subPuzzle en cas de changement de personnage
        if (m_interactDetection.m_isInSubPuzzle && m_gamepad.buttonEast.isPressed || m_gamepad.buttonWest.isPressed)    //(m_interactDetection.m_isInSubPuzzle && Input.GetKeyDown(m_inputs.inputHuman) || Input.GetKeyDown(m_inputs.inputRobot))
        {
            if(m_interactDetection.enabled)m_interactDetection.PuzzleDeactivation();
        }
    }


    IEnumerator Rumble()
    {
        m_gamepad.SetMotorSpeeds(m_lowA, m_highA);
        yield return new WaitForSeconds(m_rumbleDuration);
        m_gamepad.SetMotorSpeeds(0, 0);
    }
    
    
    /// <summary>
    /// Place correctly an element with its rect transform
    /// </summary>
    /// <param name="p_o">The game object you want to move</param>
    /// <param name="p_x">Its X coordinate</param>
    /// <param name="p_y">Its Y coordinate</param>
    private void SetRectPosition(GameObject p_o, float p_x, float p_y) {
        if (p_o.TryGetComponent(out RectTransform goRect)) {
            goRect.anchorMin = new Vector2((m_centerShift * m_offset) + m_offset * p_x, m_offset * p_y);
            goRect.anchorMax = new Vector2((m_centerShift * m_offset) + m_offset * (p_x+1), m_offset * (p_y+1));

            goRect.localPosition = Vector3.zero;

            goRect.anchoredPosition = Vector2.zero;
        }
    }
    
    
    /// <summary>
    /// Is called when this gameObject is setActive(false)
    /// Is used to destroy everything it created
    /// </summary>
    void OnDisable()
    {
        m_errorDone = 0;
        m_findPiece = 0;
        
        m_selectorTransform = null;
        
        m_stockPieces.Clear();
        m_potentialPieces.Clear();
        m_correctPieces.Clear();
        m_foundPieces.Clear();
        
        // https://memegenerator.net/instance/44816816/plotracoon-we-shall-destroy-them-all
        //As all the gameobjects we instantiated are child of this gameobject, we just have to erase all the children of this
        foreach(Transform child in gameObject.transform) {
            Destroy(child.gameObject);
        }
        
    }
    
    
    // Private helpers
    private Gamepad GetGamepad()
    {
        return Gamepad.all.FirstOrDefault(g => m_playerInput.devices.Any(d => d.deviceId == g.deviceId));

        #region Linq Query Equivalent Logic
        //Gamepad gamepad = null;
        //foreach (var g in Gamepad.all)
        //{
        //    foreach (var d in _playerInput.devices)
        //    {
        //        if(d.deviceId == g.deviceId)
        //        {
        //            gamepad = g;
        //            break;
        //        }
        //    }
        //    if(gamepad != null)
        //    {
        //        break;
        //    }
        //}
        //return gamepad;
        #endregion
    }
}
