using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestRobotManager : MonoBehaviour
{
	public GameObject m_canvas;		//background de réussite de subPuzzle

	public GameObject[] m_piecePrefabs;		//tableau des pièces à instancier


	[System.Serializable]
	public class Puzzle
	{
		public int m_winValue;
		public int m_curValue;

		public int m_width;
		public int m_height;
		public piece[,] m_pieces;

	}
	
	public Puzzle m_puzzle;


	// Use this for initialization
	void Start () {

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
		m_puzzle.m_pieces = new piece[m_puzzle.m_width, m_puzzle.m_height];

		int[] auxValues = {0, 0, 0, 0};	//valeur de la pièce à poser au départ


		for (int i = 0; i < m_puzzle.m_height; i++) {
			for (int j = 0; j < m_puzzle.m_width; j++) {

				//width restrictions
				if (j == 0)
					auxValues [3] = 0;
				else
					auxValues [3] = m_puzzle.m_pieces [j - 1, i].m_values[1];

				if (j == m_puzzle.m_width - 1)
					auxValues [1] = 0;
				else
					auxValues [1] = Random.Range (0, 2);


				//height restrictions
				if (i == 0)
					auxValues [2] = 0;
				else
					auxValues [2] = m_puzzle.m_pieces [j, i - 1].m_values [0];

				if (i == m_puzzle.m_height - 1)
					auxValues [0] = 0;
				else
					auxValues [0] = Random.Range (0, 2);


				//tells us piece type
				int valueSum = auxValues[0] + auxValues[1] + auxValues[2] + auxValues[3];


				if (valueSum == 2 && auxValues[0] != auxValues[2])
					valueSum = 5;

				GameObject go =  (GameObject) Instantiate (m_piecePrefabs[valueSum], new Vector3 (j, i, 0), Quaternion.identity);
			
				
				while (go.GetComponent<piece> ().m_values [0] != auxValues [0] ||
				      go.GetComponent<piece> ().m_values [1] != auxValues [1] ||
				      go.GetComponent<piece> ().m_values [2] != auxValues [2] ||
				      go.GetComponent<piece> ().m_values [3] != auxValues [3])
				{
					go.GetComponent<piece> ().RotatePiece ();
				}

				m_puzzle.m_pieces [j, i] = go.GetComponent<piece> ();
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
					if (m_puzzle.m_pieces [w, h].m_values [0] == 1 && m_puzzle.m_pieces [w, h + 1].m_values [2] == 1)
						value++;
				
				//compare right
				if(w!=m_puzzle.m_width-1)
					if (m_puzzle.m_pieces [w, h].m_values [1] == 1 && m_puzzle.m_pieces [w + 1, h].m_values [3] == 1)
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
			if (m_puzzle.m_pieces [p_width, p_height].m_values [0] == 1 && m_puzzle.m_pieces [p_width, p_height + 1].m_values [2] == 1)
				value++;


		//compare right
		if(p_width!=m_puzzle.m_width-1)
			if (m_puzzle.m_pieces [p_width, p_height].m_values [1] == 1 && m_puzzle.m_pieces [p_width + 1, p_height].m_values [3] == 1)
				value++;


		//compare left
		if (p_width != 0)
			if (m_puzzle.m_pieces [p_width, p_height].m_values [3] == 1 && m_puzzle.m_pieces [p_width - 1, p_height].m_values [1] == 1)
				value++;

		//compare bottom
		if (p_height != 0)
			if (m_puzzle.m_pieces [p_width, p_height].m_values [2] == 1 && m_puzzle.m_pieces [p_width, p_height-1].m_values [0] == 1)
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
				winValue += j;
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
				piece.RotatePiece ();
			}
		}
	}

	
}
