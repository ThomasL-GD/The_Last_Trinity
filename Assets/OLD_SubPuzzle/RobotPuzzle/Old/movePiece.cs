using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class movePiece : MonoBehaviour
{

    /// <summary>
    /// angle de rotation d'un bloc
    /// </summary>
    private float m_realRotation;
    
    /// <summary>
    /// Création d'un tableau de valeurs
    /// </summary>
    public bool[] m_values;

    
/*
    public void RotatePiece()
    {
        m_realRotation -= 90;

        if (m_realRotation == 360) m_realRotation = 0;
        
        transform.rotation = Quaternion.Euler(0, 0, m_realRotation);

        //Change la valeur qui est attribuée à une face en fonction du symbole représenté
        RotateValue();
    }
    
    
    public void RotateValue()
    {
        bool aux = m_values[0];
        
        for (int i = 0; i < m_values.Length-1; i++)
        {
            m_values[i] = m_values[i + 1];
        }
        m_values[3] = aux;
    }
*/
    
    
}
