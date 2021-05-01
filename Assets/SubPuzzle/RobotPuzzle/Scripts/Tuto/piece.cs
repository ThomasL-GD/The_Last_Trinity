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
        
        //Si la rotation n'est pas fixe, soit m_realRotation, alors le décalage se règle pour avoir la bonne valeur de rotation (exemple: 90,5 ou 89,7 ==> 90)
        if (transform.root.eulerAngles.z != m_realRotation) {
            transform.rotation = Quaternion.Lerp (transform.rotation, Quaternion.Euler (0, 0, m_realRotation), m_speed);
        }
    }
    

    void OnMouseDown()
    {

        int difference = -m_testRobotManager.QuickSweep((int)transform.position.x,(int)transform.position.y);   //valeur de position au départ

        RotatePiece (); //Fonction qui tourne la pièce ainsi que les valeurs qui lui sont attribbués

        difference += m_testRobotManager.QuickSweep((int)transform.position.x,(int)transform.position.y);   //valeur de position après rotation de la pièce
        
        m_testRobotManager.m_puzzle.m_curValue += difference;

        if (m_testRobotManager.m_puzzle.m_curValue == m_testRobotManager.m_puzzle.m_winValue)  m_testRobotManager.Win ();
    }

    /// <summary>
    /// Fonction qui sert à tourner la pièce d'un certain angle
    /// fonction mise en publique parce qu'on l'appelle dans testRobotManager
    /// </summary>
    public void RotatePiece()
    {
        m_realRotation += 90;   //valeur de rotation

        if (m_realRotation == 360)
            m_realRotation = 0;

        RotateValues ();    //rotation des valeurs
    }

    /// <summary>
    /// Fonction qui sert à modifier les valeurs en fonction de la rotation de la pièce et des lignes de sortie de chaque pièce
    /// </summary>
    private void RotateValues()
    {
        int firstValue = m_values [0]; //première valeur de la pièce

        //la valeur actuelle sur chaque face prends la valeur suivante, c'est ce qui lie la rotation de la pièce à la valeur de la face de chaque pièce 
        for (int i = 0; i < m_values.Length-1; i++) {
            m_values [i] = m_values [i + 1];
        }
        m_values [3] = firstValue; //si la valeur est supérieure à celle de la longueur du tableau, alors on donne lui donne la première valeur puisqu'on a fait un tour
    }
}
