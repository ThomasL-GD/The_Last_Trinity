using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.Rendering;
using Random = UnityEngine.Random;

public class RobotPuzzleManager : MonoBehaviour
{
	[Tooltip("Image de réussite de subPuzzle")] public GameObject m_victoryCanvas;

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

	[System.Serializable]
	public class Puzzle
	{
		[HideInInspector] public int m_winValue;	//variable qui indique le nombre de connexions à atteindre pour réussir le puzzle
		[HideInInspector] public int m_curValue;	//variable qui indique la valeur actuelle du nombre de connexions dans le subpuzzle

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
	}
	private Selector m_selector = new Selector();
	
	[SerializeField] [Tooltip("Carré de selection qui se déplace entre les différentes instances de pièces présentes")] private GameObject m_prefabSelector = null;
	
	//La position de la première case
	private Vector3 m_initialPos = Vector3.zero;

	//transform du sélecteur
	private Transform m_selectorTransform = null;
	
	//liste des pièces dans la scène
	[Tooltip("For debug only")] private List<GameObject> m_scenePieces = new List<GameObject>();

	[SerializeField] [Tooltip("autorisation de bouger sur des cases vides")] private bool m_canMoveOnEmpty = false;

	private DebugUI.Panel m_panel = null;
	
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

		if (Screen.width >= Screen.height)
		{
			m_panel 
		}
		else
		{
			
		}
		
	}
	
	void OnEnable(){

		m_victoryCanvas.SetActive (false);		//encadrement de réussite de subpuzzle cachée
		
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
		GameObject instance = Instantiate(m_prefabSelector, m_initialPos, transform.rotation, gameObject.transform);

		//le sélecteur se positionne  à la position
		m_selectorTransform = instance.transform;
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
				if (j == 0) //Si la pièce actuelle se situe à la position minimum à gauche (donc il n'y a rien à gauche)
					auxValues[3] = false; //la valeur de la connexion à gauche est fausse;
				else
					auxValues[3] = m_puzzle.m_pieces[j - 1, i].m_values[1];	//Sinon la valeur de la connexion à gauche de la pièce actuelle est égale à la valeur de la connexion à droite de la pièce à gauche

				if (j == m_puzzle.m_width - 1)	//Si la pièce se situe à la position maximum à droite (donc il n'y a pas de pièce encore à droite)
					auxValues [1] = false;	//la valeur de la connexion à droite est fausse
				else
					auxValues [1] = (Random.Range(0, 2) == 1);	//Sinon la valeur de la connexion à droite est soit vraie, soit fausse


				//restrictions sur la hauteur
				if (i == 0)	//Si la pièce actuelle se situe à la position minimum en hauteur (donc il n'y a pas de pièce en-dessous)
					auxValues [2] = false;	//la valeur de la connexion en bas est fausse
				else
					auxValues [2] = m_puzzle.m_pieces [j, i - 1].m_values [0];	//Sinon la valeur de la connexion en bas de la pièce actuelle = la valeur de la connexion en haut de la pièce juste en-dessous	

				if (i == m_puzzle.m_height - 1)	//Si la pièce actuelle se situe à la position maximum en hauteur (donc il n'y a pas de pièces au-dessus)
					auxValues [0] = false;	//la valeur de la connexion en haut est fausse
				else
					auxValues [0] = (Random.Range (0, 2)== 1);	//Sinon la valeur de la connexion en haut de la pièce actuelle est soit vraie soit fausse

				
				//indique le type pièce à instancier
				int valueSum = 0;

				//check de chaque valeur de chaque face dans auxValues afin de choisir quel type de pièce instancier
				for (int k = 0; k < auxValues.Length; k++)
				{
					if (auxValues[k]) valueSum++;	//à chaque fois qu'une connexion a été trouvé, la pièce à instancier devra comprendre une connexion supplémentaire
				}
				
				
				if (valueSum == 2 && auxValues[0] != auxValues[2]) valueSum = 5;	//Si la pièce à instancier possède deux connexions et que la valeur de la face du haut est différente de la face en bas, instancier la pièce corner

				//instanciation du prefab en fonction de la valeur de valueSum
				GameObject go = (GameObject) Instantiate (m_piecePrefabs[valueSum], new Vector3 (j, i, 0), Quaternion.identity, gameObject.transform);		//4ème paramètre met en enfant du gameobject principal
				
				m_scenePieces.Add(go);
				
				//récupération de la position de la première prefab instanciée
				//position sert à placer le sélecteur qui prend position de m_initialPos
				if (j == 0 && i == 0) m_initialPos = transform.position;
				
				//Récupération du script sur chaque pièce
				PieceBehaviour pieceScript = go.GetComponent<PieceBehaviour>();
				
				//à l'instance, prend le script de la pièce et se met dedans
				pieceScript.m_RobotPuzzleManager = gameObject.GetComponent<RobotPuzzleManager>();
				
				//Tourne la pièce pour éviter qu'elle ne soit bien positionnée dès le départ
				while (pieceScript.m_values [0] != auxValues [0] || pieceScript.m_values [1] != auxValues [1] || pieceScript.m_values [2] != auxValues [2] || pieceScript.m_values [3] != auxValues [3])
				{
					pieceScript.RotatePiece ();
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
		m_victoryCanvas.SetActive (true);
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
		if (Input.GetKeyDown(KeyCode.LeftArrow) || Input.GetKeyDown(KeyCode.RightArrow) || Input.GetKeyDown(KeyCode.UpArrow) || Input.GetKeyDown(KeyCode.DownArrow))
		{
			for (int i = 0; i < m_scenePieces.Count; i++) //pour chaque pièce présente dans la scène
			{
				if (m_selectorTransform.position == m_scenePieces[i].transform.position) //si le sélecteur est à la même position que la pièce actuelle de scenePieces
				{
					//déplacement du sélecteur
					if (Input.GetKeyDown(KeyCode.LeftArrow) && m_selector.x > m_puzzle.m_width - m_puzzle.m_width) //Déplacement a gauche si position X sélecteur > position  X  première prefab instanciée
					{
						//Récupération du script sur la pièce de puzzle
						PieceBehaviour pieceScript = m_scenePieces[i-1].GetComponent<PieceBehaviour>();
						
						//vérifie que la pièce à gauche de là où se situe le sélecteur possède au moins une connexion
						if(pieceScript.m_isEmptyPiece == false || m_canMoveOnEmpty) m_selector.x--;
					}
					else if (Input.GetKeyDown(KeyCode.RightArrow) && m_selector.x < m_puzzle.m_width - 1) //Déplacement à droite si position  X sélecteur < valeur largeur tableau prefab
					{
						//Récupération du script sur la pièce de puzzle
						PieceBehaviour pieceScript = m_scenePieces[i+1].GetComponent<PieceBehaviour>();
						
						if(pieceScript.m_isEmptyPiece == false || m_canMoveOnEmpty) m_selector.x++;		//vérifie que la pièce à gauche de là où se situe le sélecteur possède au moins une connexion
					}
					else if (Input.GetKeyDown(KeyCode.UpArrow) && m_selector.y > -m_puzzle.m_height + 1) //Déplacement en haut si position Y sélecteur > position Y dernière prefab
					{
						//Récupération du script sur la pièce de puzzle
						PieceBehaviour pieceScript = m_scenePieces[i+m_puzzle.m_width].GetComponent<PieceBehaviour>();
						
						if(pieceScript.m_isEmptyPiece == false || m_canMoveOnEmpty) m_selector.y--;		//vérifie que la pièce à gauche de là où se situe le sélecteur possède au moins une connexion
					}
					else if (Input.GetKeyDown(KeyCode.DownArrow) && m_selector.y < m_puzzle.m_height - m_puzzle.m_height) //Déplacement en bas si position Y sélecteur < 0
					{
						//Récupération du script sur la pièce de puzzle
						PieceBehaviour pieceScript = m_scenePieces[i-m_puzzle.m_width].GetComponent<PieceBehaviour>();
						
						if(pieceScript.m_isEmptyPiece == false || m_canMoveOnEmpty) m_selector.y++;		//vérifie que la pièce à gauche de là où se situe le sélecteur possède au moins une connexion
					}
				}
			}

			m_selectorTransform.position = new Vector3(m_initialPos.x + m_selector.x, m_initialPos.y - m_selector.y, m_initialPos.z);	//nouvelle position du sélecteur
		}
		
		
		if (Input.GetKeyDown(KeyCode.Space))
		{
			for (int i = 0; i < m_scenePieces.Count; i++) //pour chaque pièce présente dans la scène
			{
				if (m_selectorTransform.position == m_scenePieces[i].transform.position) //si le sélecteur est à la même position que la pièce actuelle de scenePieces
				{
					//Récupération du script sur la pièce de puzzle
					PieceBehaviour pieceScript = m_scenePieces[i].GetComponent<PieceBehaviour>();

					//rotation de la pièce
					pieceScript.SweepPiece();
				}
			}
		}
		
	}
	
}
