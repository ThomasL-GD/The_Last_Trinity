using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using Random = UnityEngine.Random;

public class RobotPuzzleManager : MonoBehaviour
{
	[Tooltip("Image de réussite de subPuzzle")] public GameObject m_canvas;

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
		public int m_winValue;	//variable qui indique le nombre de connexions à atteindre pour réussir le puzzle
		public int m_curValue;	//variable qui indique la valeur actuelle du nombre de connexions dans le subpuzzle

		public int m_width;		//variable qui indique la largeur du tableau
		public int m_height;	//variable qui indique la hauteur du tableau
		public PieceBehaviour[,] m_pieces;	//tableau à deux dimensions des positions des pièces
	}
	
	public Puzzle m_puzzle;	//variable permettant d'accéder au script Puzzle au-dessus

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

	// Use this for initialization
	void OnEnable(){

		m_canvas.SetActive (false);		//encadrement de réussite de subpuzzle cachée
		
		if (m_puzzle.m_width == 0 || m_puzzle.m_height == 0) {
			Debug.LogError ("Please set the dimensions");
			Debug.Break ();
		}
		
		GeneratePuzzle ();	//création du puzzle et instanciation des pièces

		m_puzzle.m_winValue = GetWinValue ();	//récupération dans une variable du nombre de connexions maximum possible dans la puzzle

		Shuffle ();	//rotation des pièces d'une valeur aléatoire entre 0, 90, 180 et 270 à l'instanciation

		m_puzzle.m_curValue=Sweep ();

	}


	/// <summary>
	/// Fonction qui va générer le puzzle aléatoirement en fonction des pièces qui sont posées
	/// l'une après l'autre afin de faire un puzzle réussissable
	/// </summary>
	void GeneratePuzzle()
	{
		m_puzzle.m_pieces = new PieceBehaviour[m_puzzle.m_width, m_puzzle.m_height];

		bool[] auxValues = {false, false, false, false};	//valeur de la pièce à poser au départ


		for (int i = 0; i < m_puzzle.m_height; i++) {
			for (int j = 0; j < m_puzzle.m_width; j++) {

				//width restrictions
				if (j == 0)
					auxValues [3] = false;
				else
					auxValues [3] = m_puzzle.m_pieces [j - 1, i].m_values[1];

				if (j == m_puzzle.m_width - 1)
					auxValues [1] = false;
				else
					auxValues [1] = (Random.Range(0, 2) == 1);


				//height restrictions
				if (i == 0)
					auxValues [2] = false;
				else
					auxValues [2] = m_puzzle.m_pieces [j, i - 1].m_values [0];

				if (i == m_puzzle.m_height - 1)
					auxValues [0] = false;
				else
					auxValues [0] = (Random.Range (0, 2)== 1);

				
				//tells us piece type
				int valueSum = 0;

				for (int k = 0; k < auxValues.Length; k++)
				{
					if (auxValues[k]) valueSum++;
				}
				

				if (valueSum == 2 && auxValues[0] != auxValues[2])
					valueSum = 5;

				GameObject go = (GameObject) Instantiate (m_piecePrefabs[valueSum], new Vector3 (j, i, 0), Quaternion.identity);	//instanciation du prefab
				
				PieceBehaviour pieceScript = go.GetComponent<PieceBehaviour>();

				
				pieceScript.m_RobotPuzzleManager = gameObject.GetComponent<RobotPuzzleManager>();	//à l'instance, prend le script de la pièce et se met dedans
				
				
				while (pieceScript.m_values [0] != auxValues [0] || pieceScript.m_values [1] != auxValues [1] || pieceScript.m_values [2] != auxValues [2] || pieceScript.m_values [3] != auxValues [3])
				{
					pieceScript.RotatePiece ();
				}

				m_puzzle.m_pieces [j, i] = pieceScript;
			}
		}
	}


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
		m_canvas.SetActive (true);
	}

	public int QuickSweep(int p_width,int p_height)
	{
		int value = 0;

		//compares top
		if(p_height!=m_puzzle.m_height-1)
			if (m_puzzle.m_pieces [p_width, p_height].m_values [0] == true && m_puzzle.m_pieces [p_width, p_height + 1].m_values [2] == true)
				value++;


		//compare right
		if(p_width!=m_puzzle.m_width-1)
			if (m_puzzle.m_pieces [p_width, p_height].m_values [1] == true && m_puzzle.m_pieces [p_width + 1, p_height].m_values [3] == true)
				value++;


		//compare left
		if (p_width != 0)
			if (m_puzzle.m_pieces [p_width, p_height].m_values [3] == true && m_puzzle.m_pieces [p_width - 1, p_height].m_values [1] == true)
				value++;

		
		//compare bottom
		if (p_height != 0)
			if (m_puzzle.m_pieces [p_width, p_height].m_values [2] == true && m_puzzle.m_pieces [p_width, p_height-1].m_values [0] == true)
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

	
}
