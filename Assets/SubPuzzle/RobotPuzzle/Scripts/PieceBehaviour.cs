using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PieceBehaviour : MonoBehaviour
{
    //script du gestionnaire de puzzle
    [HideInInspector] public RobotPuzzleManager m_RobotPuzzleManager = null;
    
    [Tooltip("tableau des valeurs vraies ou fausses")] public bool[] m_values = null;
    
    [SerializeField] [Tooltip("Vitesse de rotation des pièces")] private float m_speed = 10.0f;
    
    //Angle à partir de laquelle la pièce va se caler pour rotate dynamiquement
    private float m_realRotation = 0.0f;
    
    [Tooltip("vérifie si la pièce a au moins une connexion")] public bool m_isEmptyPiece = true;
    
    private void Start()
    {
        //détecteur de connexion sur la pièce
        for (int i = 0; i < m_values.Length; i++)
        {
            //si une connexion a été trouvé, la pièce n'est pas de type empty
            if (m_values[i] == true)
            {
                m_isEmptyPiece = false;
                i = m_values.Length;
            }
            //Si aucune connexion a été trouvé, la pièce n'en a donc pas et le joueur ne peut pas se déplacer sur cette case
            else m_isEmptyPiece = true;
        }
        
    }

    // Update is called once per frame
    void Update ()
    {
        //Si la rotation n'est pas fixe, soit m_realRotation, alors le décalage se règle pour avoir la bonne valeur de rotation (exemple: 90,5 ou 89,7 ==> 90)
        if (transform.root.eulerAngles.z != m_realRotation) {
            transform.rotation = Quaternion.Lerp (transform.rotation, Quaternion.Euler (0, 0, m_realRotation), m_speed);
        }
    }
    

    /// <summary>
    /// Fonction qui implique la rotation de pièce et indique le changement de valeurs de la pièce sur chaque face
    /// </summary>
    public void SweepPiece()
    {
        int difference = -m_RobotPuzzleManager.QuickSweep((int)transform.position.x,(int)transform.position.y);   //valeur de position au départ

        RotatePiece (); //Fonction qui tourne la pièce ainsi que les valeurs qui lui sont attribbués

        difference += m_RobotPuzzleManager.QuickSweep((int)transform.position.x,(int)transform.position.y);   //valeur de position après rotation de la pièce
        
        m_RobotPuzzleManager.m_puzzle.m_curValue += difference; //calcul la différence après rotation et add to curValue

        if (m_RobotPuzzleManager.m_puzzle.m_curValue == m_RobotPuzzleManager.m_puzzle.m_winValue)  m_RobotPuzzleManager.Win ();
        
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

        RotateValues();    //rotation des valeurs
    }

    /// <summary>
    /// Fonction qui sert à modifier les valeurs en fonction de la rotation de la pièce et des lignes de sortie de chaque pièce
    /// </summary>
    private void RotateValues()
    {
        bool firstValue = m_values [0]; //première valeur de la pièce

        //la valeur actuelle sur chaque face prends la valeur suivante, c'est ce qui lie la rotation de la pièce à la valeur de la face de chaque pièce 
        for (int i = 0; i < m_values.Length-1; i++) {
            m_values [i] = m_values [i + 1];
        }
        m_values [3] = firstValue; //si la valeur est supérieure à celle de la longueur du tableau, alors on donne lui donne la première valeur puisqu'on a fait un tour
    }
}
