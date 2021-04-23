using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class movePiece : MonoBehaviour
{

    /// <summary>
    /// Vitesse de rotation d'une pièce
    /// </summary>
    [SerializeField] private float m_speed = 200.0f;
    
    /// <summary>
    /// angle de rotation d'un bloc
    /// </summary>
    private float m_realRotation;
    
    /// <summary>
    /// Création d'un tableau de baleurs
    /// </summary>
    public int[] m_values;

    
    private void Update()
    {
        if (transform.root.eulerAngles.z != m_realRotation)
        {
            transform.rotation = Quaternion.Lerp(transform.rotation, Quaternion.Euler(0,0,m_realRotation), m_speed);
        }
    }

    private void OnMouseDown()
    {
        RotatePiece();
    }

    public void RotatePiece()
    {
        m_realRotation -= 90;

        if (m_realRotation == 360) m_realRotation = 0;
        
        transform.rotation = Quaternion.Euler(0, 0, m_realRotation);

        RotateValue();
    }
    
    public void RotateValue()
    {
        int aux = m_values[0];
        
        for (int i = 0; i < m_values.Length-1; i++)
        {
            m_values[i] = m_values[i + 1];
        }
        m_values[3] = aux;
    }
    
}
