using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RobotPuzzleManager : MonoBehaviour
{
    [System.Serializable]
    public struct MyRobotPuzzle
    {
        public int m_width;
        public int m_height;
        public GameObject[,] m_robotPieces;   
    }

    public MyRobotPuzzle m_myRobotPuzzle;
    
    // Start is called before the first frame update
    void Start()
    {
        Vector2 dimension = CheckDimension();

        m_myRobotPuzzle.m_width = (int) dimension.x;
        m_myRobotPuzzle.m_height = (int) dimension.y;

        m_myRobotPuzzle.m_robotPieces = new GameObject[m_myRobotPuzzle.m_width, m_myRobotPuzzle.m_height];

        foreach (var piece in GameObject.FindGameObjectsWithTag("Piece"))
        {
            m_myRobotPuzzle.m_robotPieces[(int) piece.transform.position.x, (int) piece.transform.position.y]
                = piece.GetComponent<GameObject>();
        }

        foreach (var item in m_myRobotPuzzle.m_robotPieces)
        {
            Debug.Log(item.gameObject.name);
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

        aux.x++;
        aux.y++;

        return aux;
    }
    
    
    // Update is called once per frame
    void Update()
    {
        
    }
}
