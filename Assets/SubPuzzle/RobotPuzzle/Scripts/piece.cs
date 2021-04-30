using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class piece : MonoBehaviour
{
    public int[] m_values;    //tableau de valeur pour chaque face de chaque pièce à instancier
    
    [SerializeField] [Tooltip("Vitesse de rotation des pièces")] private float m_speed;
    
    private float m_realRotation; //Angle de rotation d'une pièce
    
    public TestRobotManager m_testRobotManager;
    
    // Use this for initialization
    void Start () {
        m_testRobotManager = GameObject.FindGameObjectWithTag ("GameController").GetComponent<TestRobotManager> ();
    }
	
    // Update is called once per frame
    void Update () {
        
        if (transform.root.eulerAngles.z != m_realRotation) {
            transform.rotation = Quaternion.Lerp (transform.rotation, Quaternion.Euler (0, 0, m_realRotation), m_speed);
        }
    }



    void OnMouseDown()
    {

        int difference = -m_testRobotManager.QuickSweep((int)transform.position.x,(int)transform.position.y);

        RotatePiece ();

        difference += m_testRobotManager.QuickSweep((int)transform.position.x,(int)transform.position.y);
        
        m_testRobotManager.m_puzzle.m_curValue += difference;

        if (m_testRobotManager.m_puzzle.m_curValue == m_testRobotManager.m_puzzle.m_winValue)
            m_testRobotManager.Win ();
    }

    public void RotatePiece()
    {
        m_realRotation += 90;

        if (m_realRotation == 360)
            m_realRotation = 0;

        RotateValues ();
    }

    private void RotateValues()
    {
        int aux = m_values [0];

        for (int i = 0; i < m_values.Length-1; i++) {
            m_values [i] = m_values [i + 1];
        }
        m_values [3] = aux;
    }
}
