using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using TMPro;
using UnityEngine;
using Random = UnityEngine.Random;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.DualShock;

public class RobotPuzzleManager : MonoBehaviour {

	[Serializable]
	public class PiecePrefabs
	{
		public GameObject prefabEmpty = null;
		public GameObject prefabOneDirection = null;
		public GameObject prefabStraightLine = null;
		public GameObject prefabCorner = null;
		public GameObject prefabTForm = null;
		public GameObject prefabCross = null;
	}

	[SerializeField] [Tooltip("Tableau des pièces à instancier avec leur nom")] private PiecePrefabs m_piecesPrefabClass=null;
	[HideInInspector] [Tooltip("Tableau des pièces à instancier")] public GameObject[] m_piecePrefabs;
	//liste des pièces dans la scène
	[Tooltip("For debug only")] private List<GameObject> m_scenePieces = new List<GameObject>();
	
	[System.Serializable]
	public class Puzzle
	{
		[Header("Win Condition")]
		[HideInInspector] public int m_winValue;	//variable qui indique le nombre de connexions à atteindre pour réussir le puzzle
		[HideInInspector] public int m_curValue;	//variable qui indique la valeur actuelle du nombre de connexions dans le subpuzzle

		[Header("Dimensions")]
		public int m_width;		//variable qui indique la largeur du tableau
		public int m_height;	//variable qui indique la hauteur du tableau
		public PieceBehaviour[,] m_pieces;	//tableau à deux dimensions des positions des pièces
	}
	
	public Puzzle m_puzzle;	//variable permettant d'accéder au script Puzzle au-dessus
	
	public class Selector
	{
		//coordonnées du sélecteur
		public int x = 0;
		public int y = 0;
		public RectTransform rect = null;

		public Selector(int p_x, int p_y) {
			x = p_x;
			y = p_y;
		}
	}
	private Selector m_selector = new Selector(0, 0);
	
	[Header("Sélecteur")]
	[SerializeField] [Tooltip("Carré de selection qui se déplace entre les différentes instances de pièces présentes")] private GameObject m_prefabSelector = null;
	[SerializeField] [Tooltip("autorisation de bouger sur des cases vides")] private bool m_canMoveOnEmpty = true;

	private float m_offset = 0.5f; //The size of each piece (in anchor values)
	
	[Header("SO Input")]
	[SerializeField] [Tooltip("controller input")] public SOInputMultiChara m_inputs = null;
	[Tooltip("position limite de joystick")] private float m_limitPosition = 0.5f;
	[HideInInspector] [Tooltip("variable de déplacement en points par points du sélecteur")] private bool m_hasMoved = false;
	
	[HideInInspector] [Tooltip("Script d'intéraction entre le personnage et l'objet comprenant le subpuzzle")] public Interact_Detection m_interactDetection = null;
	
	public static Gamepad m_gamepad = DualShockGamepad.current;

	private void Awake()
	{
		m_piecePrefabs = new GameObject[6];	//tableau. Le 6 est arbitraire et représente le nombre de pièces différentes

		m_piecePrefabs[0] = m_piecesPrefabClass.prefabEmpty;
		m_piecePrefabs[1] = m_piecesPrefabClass.prefabOneDirection;
		m_piecePrefabs[2] = m_piecesPrefabClass.prefabStraightLine;
		m_piecePrefabs[3] = m_piecesPrefabClass.prefabTForm;
		m_piecePrefabs[4] = m_piecesPrefabClass.prefabCross;
		m_piecePrefabs[5] = m_piecesPrefabClass.prefabCorner;

		for (int i = 1; i < m_piecePrefabs.Length; i++)
		{
			if (m_piecePrefabs[i] == null)
			{
				Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO PUT THE PREFABS FOR THE PIECES !");
				gameObject.SetActive(false);
			}
			else if (!m_piecePrefabs[i].TryGetComponent<PieceBehaviour>(out PieceBehaviour pb))
			{
				Debug.LogError("JEEZ ! THE GAME DESIGNER PUT PREFABS FOR PIECES THAT DOESN'T HAVE THE RIGHT SCRIPT ON THEM !");
				gameObject.SetActive(false);
			}
		}
	}
	
	void OnEnable(){
			
		//We calculate its initial position
		m_offset = 0f;
		if (m_puzzle.m_width > m_puzzle.m_height) {
			m_offset = (1f/m_puzzle.m_width);
		}
		else {
			m_offset = (1f/m_puzzle.m_height);
		}

		//We resize the panel in order for it to be a square
		m_interactDetection.SquarePanelToScreen();
		
		if (m_puzzle.m_width == 0 || m_puzzle.m_height == 0) {
			Debug.LogError ("JEEZ ! THE GAME DESIGNER FORGOT TO PUT THE DIMENSIONS OF THE ARRAY !");
			Debug.Break ();
		}
		
		//création du puzzle et instanciation des pièces
		GeneratePuzzle ();
		
		//récupération dans une variable du nombre de connexions maximum possible dans la puzzle
		m_puzzle.m_winValue = GetWinValue ();
		
		//rotation des pièces d'une valeur aléatoire entre 0, 90, 180 et 270 à l'instanciation
		Shuffle ();
		
		//récupération d'une nombre de connexions présentes sur une pièce
		m_puzzle.m_curValue=Sweep ();
		
		//création du selecteur dans la scène
		GameObject instance = Instantiate(m_prefabSelector, transform.position, transform.rotation, gameObject.transform);

		if (instance.TryGetComponent(out RectTransform rectT)) {
			
			rectT.anchorMin = new Vector2(0,0);
			rectT.anchorMax = new Vector2(m_offset,m_offset);

			rectT.localPosition = Vector3.zero;
			rectT.anchoredPosition = Vector2.zero;
			
			//We create a selector to stock its coordinates with int in order to have a better navigation
			m_selector = new Selector(0, 0) {rect = rectT};
		}
		else {
			Debug.LogError ("JEEZ ! THE GAME DESIGNER PUT A WRONG PREFAB FOR THE SELECTOR, IT MUST BE A UI ELEMENT WITH A RECT TRANSFORM !");
		}
		
		m_gamepad = GetGamepad();
	}


	/// <summary>
	/// Fonction qui va générer le puzzle aléatoirement en fonction des pièces qui sont posées
	/// l'une après l'autre afin de faire un puzzle réussissable
	/// </summary>
	void GeneratePuzzle()
	{
		m_puzzle.m_pieces = new PieceBehaviour[m_puzzle.m_width, m_puzzle.m_height];	//pièce actuelle à poser au nouvel emplacement

		bool[] auxValues = {false, false, false, false};	//valeur de la pièce à poser au départ

		for (int i = 0; i < m_puzzle.m_height; i++) {
			for (int j = 0; j < m_puzzle.m_width; j++) {

				//restrictions sur la largeur
				if (j == 0) //Si la pièce actuelle se situe à la position minimum sur la largeur
					auxValues[3] = false; //la valeur de la connexion à gauche est fausse;
				else
					auxValues[3] = m_puzzle.m_pieces[j - 1, i].m_values[1];	//Ensuite la valeur de la connexion à gauche de la pièce actuelle est égale à la valeur de la connexion à droite de la pièce à gauche

				if (j == m_puzzle.m_width - 1)	//Si la pièce se situe à la position maximum sur la largeur
					auxValues [1] = false;	//la valeur de la connexion à droite est fausse
				else
					auxValues [1] = (Random.Range(0, 2) == 1);	//Ensuite la valeur de la connexion à droite est soit vraie, soit fausse


				//restrictions sur la hauteur
				if (i == 0)	//Si la pièce actuelle se situe à la position minimum sur la hauteur
					auxValues [2] = false;	//la valeur de la connexion en bas est fausse
				else
					auxValues [2] = m_puzzle.m_pieces [j, i - 1].m_values [0];	//Ensuite la valeur de la connexion en bas de la pièce actuelle est la même que la valeur de la connexion en haut de la pièce juste en-dessous	

				if (i == m_puzzle.m_height - 1)	//Si la pièce actuelle se situe à la position maximum sur la hauteur
					auxValues [0] = false;	//la valeur de la connexion en haut est fausse
				else
					auxValues [0] = (Random.Range (0, 2)== 1);	//Ensuite la valeur de la connexion en haut de la pièce actuelle est soit vraie, soit fausse

				
				//indique le nombre de connexions que la pièce possède
				int valueSum = 0;

				//check de chaque valeur de chaque face dans auxValues afin de choisir quel type de pièce instancier
				for (int k = 0; k < auxValues.Length; k++)
				{
					if (auxValues[k]) valueSum++;	//à chaque fois qu'une connexion a été trouvé, la pièce à instancier devra comprendre une connexion supplémentaire
				}
				
				
				if (valueSum == 2 && auxValues[0] != auxValues[2]) valueSum = 5;	//Si la pièce à instancier possède deux connexions et que la valeur de la face du haut est différente de la face en bas, instancier la pièce corner

				
				//instanciation du prefab en fonction de la valeur de valueSum
				GameObject go = (GameObject) Instantiate (m_piecePrefabs[valueSum], new Vector3 (j, i, 0), Quaternion.identity, gameObject.transform);		//4ème paramètre met en enfant du gameobject principal
				if (go.TryGetComponent(out RectTransform goRect)) {
					goRect.anchorMin = new Vector2(m_offset * j, m_offset * i);
					goRect.anchorMax = new Vector2(m_offset * (j+1), m_offset * (i+1));

					goRect.localPosition = Vector3.zero;

					goRect.anchoredPosition = Vector2.zero;
				}
				
				m_scenePieces.Add(go);
				
				//Récupération du script sur chaque pièce
				PieceBehaviour pieceScript = go.GetComponent<PieceBehaviour>();
				
				//à l'instance, prend le script de la pièce et se met dedans
				pieceScript.m_RobotPuzzleManager = gameObject.GetComponent<RobotPuzzleManager>();
				
				//Tourne la pièce pour qu'elle ne soit bien positionnée dès le départ
				for (int k = 0; k < 4; k++)
				{
					if (!(pieceScript.m_values [0] != auxValues [0] || pieceScript.m_values [1] != auxValues [1] || pieceScript.m_values [2] != auxValues [2] || pieceScript.m_values [3] != auxValues [3]))
					{
						k = 4;
					}
					else{pieceScript.RotatePiece ();}
				}
				
				//Récupération du script sur la pièce actuelle
				m_puzzle.m_pieces [j, i] = pieceScript;
			}
		}
	}

	
	/// <summary>
	/// Fonction de comparaison des valeurs d'une pièce par rapport aux pièces adjacentes
	/// Cette fonction se fait une fois que chaque pièce a été instancié
	/// </summary>
	/// <returns></returns>
	public int Sweep()
	{
		int value = 0;

		for (int h = 0; h < m_puzzle.m_height; h++) {
			for (int w = 0; w < m_puzzle.m_width; w++) {

				//compares top
				if(h!=m_puzzle.m_height-1)
					if (m_puzzle.m_pieces [w, h].m_values [0] == true && m_puzzle.m_pieces [w, h + 1].m_values [2] == true)
						value++;
				
				//compare right
				if(w!=m_puzzle.m_width-1)
					if (m_puzzle.m_pieces [w, h].m_values [1] == true && m_puzzle.m_pieces [w + 1, h].m_values [3] == true)
						value++;
				
				
			}
		}
		return value;
	}


	/// <summary>
	/// activation du canvas de victoire après réussite de puzzle
	/// </summary>
	public void Win()
	{
		m_interactDetection.m_achieved = true;
		m_interactDetection.m_canMove = false;
		if(m_interactDetection.enabled)m_interactDetection.PuzzleDeactivation();
	}
	
    

	/// <summary>
	/// Fonction qui implique la rotation de pièce et indique le changement de valeurs de la pièce sur chaque face
	/// </summary>
	public void SweepPiece(int p_x, int p_y)
	{
		//Debug.Log("test 2");
		int difference = -QuickSweep(p_x,p_y);   //valeur de position au départ

		m_puzzle.m_pieces[p_x,p_y].RotatePiece (); //Fonction qui tourne la pièce ainsi que les valeurs qui lui sont attribués

		difference += QuickSweep(p_x,p_y);   //valeur de position après rotation de la pièce
        
		m_puzzle.m_curValue += difference; //calcul la différence après rotation et add to curValue

		if (m_puzzle.m_curValue == m_puzzle.m_winValue)  Win ();
        
	}

	
	/// <summary>
	/// Fonction qui va comparer les connexions de la pièce actuelle avec les pièces adjacentes à chaque rotation de celle-ci
	/// </summary>
	/// <param name="p_width"></param>
	/// <param name="p_height"></param>
	/// <returns></returns>
	public int QuickSweep(int p_width,int p_height)
	{
		int value = 0;

		//compares top
		if(p_height!=m_puzzle.m_height-1)	//Si la valeur de la hauteur est inférieure à la hauteur max (pour activer une comparaison avec au-dessus, sinon ça veut dire qu'il n'y a rien au-dessus)
			if (m_puzzle.m_pieces [p_width, p_height].m_values [0] == true && m_puzzle.m_pieces [p_width, p_height + 1].m_values [2] == true) //Si la connexion en haut de la pièce actuelle est vraie et que la connexion en bas de la pièce au-dessus de la pièce actuelle est aussi vraie
				value++;


		//compare right
		if(p_width!=m_puzzle.m_width-1)	//Si la valeur de la largeur est différente de la largeur max (pour activer une comparaison avec ma droite, sinon ça veut dire qu'il n'y a rien à droite)
			if (m_puzzle.m_pieces [p_width, p_height].m_values [1] == true && m_puzzle.m_pieces [p_width + 1, p_height].m_values [3] == true)	//Si la connexion à droite de la pièce actuelle est vraie et que la connexion à gauche de la pièce à droite de la pièce actuelle est aussi vraie
				value++;


		//compare left
		if (p_width != 0)	//Si la valeur de la largeur est différente de la largeur minimum (pour activer une comparaison avec la gauche, sinon ça veut dire qu'il n'y a rien à gauche)
			if (m_puzzle.m_pieces [p_width, p_height].m_values [3] == true && m_puzzle.m_pieces [p_width - 1, p_height].m_values [1] == true)	//Si la connexion à gauche de la pièce actuelle est vraie et que la connexion à droite de la pièce à gauche de la pièce actuelle est aussi vraie
				value++;

		
		//compare bottom
		if (p_height != 0)	//Si la valeur de la hauteur est inférieure à la différente de la hauteur minimum (pour activer une comparaison avec en-dessous, sinon ça veut dire qu'il n'y a rien en-dessous)
			if (m_puzzle.m_pieces [p_width, p_height].m_values [2] == true && m_puzzle.m_pieces [p_width, p_height-1].m_values [0] == true)		//Si la connexion en bas de la pièce actuelle est vraie et que la connexion en haut de la pièce en-dessous de la pièce actuelle est aussi vraie
				value++;

		return value;
	}

	
	/// <summary>
	/// Fonction de récupération du nombre de onnexions possibles dans le puzzle
	/// On divise ensuite le nombre total par 2. 2 sorties forment une connexion
	/// </summary>
	/// <returns></returns>
	int GetWinValue()
	{
		int winValue = 0;
		
		//Pour chaque pièces instanciées, on vérifie le nombre de sorties qu'elle possède et on ajoute +1 à chaque sortie trouvée
		foreach (var piece in m_puzzle.m_pieces) {
			foreach (var j in piece.m_values) {
				if(j) winValue += 1;
			}
		}
		
		//Une fois toutes les sorties trouvées dans le puzzle, on divise cette valeur par 2 afin d'avoir le nombre de connexions maximum possibles
		winValue /= 2;
		
		return winValue;
	}
	

	/// <summary>
	/// Fonction de rotation des pièces aléatoire
	/// </summary>
	void Shuffle()
	{
		foreach (var piece in m_puzzle.m_pieces) {
			int k = Random.Range (0, 4);

			for (int i = 0; i < k; i++) {
				piece.RotatePiece();
			}
		}
	}


	private void Update()
	{
		float horizontalAxis = Input.GetAxis("Horizontal");
		float verticalAxis = Input.GetAxis("Vertical");
		bool selectorValidation = Input.GetKeyDown(m_inputs.inputRobot);

		if (!m_hasMoved && horizontalAxis < -m_limitPosition || horizontalAxis > m_limitPosition || verticalAxis >m_limitPosition || verticalAxis < -m_limitPosition)
		{
			
			//déplacement du sélecteur
			if (m_interactDetection.m_canMove && !m_hasMoved && horizontalAxis < -m_limitPosition && m_selector.x > 0) //Déplacement a gauche si position X sélecteur > position  X  première prefab instanciée
			{
				//vérifie que la pièce à gauche de là où se situe le sélecteur possède au moins une connexion
				if(m_puzzle.m_pieces[m_selector.x, m_selector.y].m_isEmptyPiece == false || m_canMoveOnEmpty) m_selector.x--;
				m_hasMoved = true;
			}
			else if (m_interactDetection.m_canMove && !m_hasMoved && horizontalAxis > m_limitPosition && m_selector.x < m_puzzle.m_width - 1) //Déplacement à droite si position  X sélecteur < valeur largeur tableau prefab
			{
				if(m_puzzle.m_pieces[m_selector.x, m_selector.y].m_isEmptyPiece == false || m_canMoveOnEmpty) m_selector.x++;		//vérifie que la pièce à gauche de là où se situe le sélecteur possède au moins une connexion
				m_hasMoved = true;
			}
			else if (m_interactDetection.m_canMove && !m_hasMoved && verticalAxis > m_limitPosition && m_selector.y < m_puzzle.m_height - 1) //Déplacement en haut si position Y sélecteur > position Y dernière prefab
			{
				if (m_puzzle.m_pieces[m_selector.x, m_selector.y].m_isEmptyPiece == false || m_canMoveOnEmpty)
				{
					m_selector.y++; //vérifie que la pièce à gauche de là où se situe le sélecteur possède au moins une connexion
					m_hasMoved = true;
				}
			}
			else if (m_interactDetection.m_canMove && !m_hasMoved && verticalAxis < -m_limitPosition && m_selector.y > 0) //Déplacement en bas si position Y sélecteur < 0
			{
				if (m_puzzle.m_pieces[m_selector.x, m_selector.y].m_isEmptyPiece == false || m_canMoveOnEmpty)
				{
					m_selector.y--; //vérifie que la pièce à gauche de là où se situe le sélecteur possède au moins une connexion
					m_hasMoved = true;
				}
			}


			m_selector.rect.anchorMin = new Vector2(m_offset * m_selector.x,m_offset * m_selector.y);
			m_selector.rect.anchorMax = new Vector2(m_offset * (m_selector.x + 1),m_offset * (m_selector.y + 1));

			m_selector.rect.localPosition = Vector3.zero;
			m_selector.rect.anchoredPosition = Vector2.zero;
	
			//m_selectorTransform.position = new Vector3(m_initialPos.x + m_selector.x, m_initialPos.y - m_selector.y, m_initialPos.z);	//nouvelle position du sélecteur
		}

		//Joystick recentré sur la manette
		if (horizontalAxis < m_limitPosition && horizontalAxis > -m_limitPosition && verticalAxis < m_limitPosition && verticalAxis > -m_limitPosition)
		{
			m_hasMoved = false;
		}
		

		if (selectorValidation) {
			//rotation de la pièce
			SweepPiece(m_selector.x, m_selector.y);
		}
		
		//Sortie du subPuzzle en cas de changement de personnage
		if (m_interactDetection.m_isInSubPuzzle && (Input.GetKeyDown(m_inputs.inputMonster) || Input.GetKeyDown(m_inputs.inputHuman) || m_gamepad.buttonSouth.isPressed))
		{
			if(m_interactDetection.enabled)m_interactDetection.PuzzleDeactivation();
		}

	}
	
	
	// Private helpers
	private Gamepad GetGamepad()
	{
		//return Gamepad.all.FirstOrDefault(g => m_playerInput.devices.Any(d => d.deviceId == g.deviceId));
		return DualShockGamepad.current;

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

	/// <summary>
	/// Is called when this gameObject is setActive(false)
	/// Is used to destroy everything it created
	/// </summary>
	void OnDisable()
	{
		m_puzzle.m_curValue = 0;
		m_puzzle.m_winValue = 0;
		
		// https://memegenerator.net/instance/44816816/plotracoon-we-shall-destroy-them-all
		//As all the gameobjects we instantiated are child of this gameobject, we just have to erase all the children of this
		foreach(Transform child in gameObject.transform) {
			Destroy(child.gameObject);
		}
	}
}
