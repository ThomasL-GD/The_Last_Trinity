using UnityEngine;
using Random = UnityEngine.Random;

public class RobotPuzzleManager : MonoBehaviour
{
    
    [System.Serializable]
    public class MyRobotPuzzle
    {
        public int m_winValue;
        public int m_currentValue;
    
        public int m_width;
        public int m_height;
        public GameObject[,] m_robotPieces;
    }
    

    public MyRobotPuzzle m_myRobotPuzzle;

    public movePiece m_movePiece;
    
    // Start is called before the first frame update
    void Start()
    {
        Vector2 dimension = CheckDimension();

        m_myRobotPuzzle.m_width = (int)dimension.x;
        m_myRobotPuzzle.m_height = (int)dimension.y;

        m_myRobotPuzzle.m_robotPieces = new GameObject[m_myRobotPuzzle.m_width, m_myRobotPuzzle.m_height];

        
        foreach (var piece in GameObject.FindGameObjectsWithTag("Piece"))
        {
            m_myRobotPuzzle.m_robotPieces[(int) piece.transform.position.x, (int) piece.transform.position.y] = piece.GetComponent<GameObject>();
        }

        
        foreach (var item in m_myRobotPuzzle.m_robotPieces)
        {
            Debug.Log(item.gameObject.name);
        }

        Shuffle();
    }


    void Shuffle()
    {
        foreach (var piece in m_myRobotPuzzle.m_robotPieces)
        {
            int k = Random.Range(0, 4);

            for (int i = 0; i < k; i++)
            {
                m_movePiece.RotatePiece();
            }
        }
    }
    


    Vector2 CheckDimension()
    {
        Vector2 aux = Vector2.zero;

        GameObject[] m_robotPieces = GameObject.FindGameObjectsWithTag("Piece");

        foreach (GameObject go in m_robotPieces)
        {
            if (go.transform.position.x > aux.x) aux.x = go.transform.position.x;
            if (go.transform.position.y > aux.y) aux.y = go.transform.position.y;
        }

        //offset par rapport à position de base
        aux.x++;
        aux.y++;

        return aux;
    }
    
    
   
}
