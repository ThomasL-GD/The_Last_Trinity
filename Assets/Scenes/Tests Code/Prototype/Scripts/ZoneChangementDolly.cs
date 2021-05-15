using System;
using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class ZoneChangementDolly : MonoBehaviour
{
    //Cinemachine cameras des trois personnages zoomées sur un rail auxiliaire
    //Effectuer un blend dans la "Main Camera" avant de régler les priorités
    [SerializeField][Tooltip("Virtual Caméra Zoomée")] private CinemachineVirtualCamera m_vCamHZ;
    [SerializeField][Tooltip("Virtual Caméra Zoomée")] private CinemachineVirtualCamera m_vCamMZ;
    [SerializeField][Tooltip("Virtual Caméra Zoomée")] private CinemachineVirtualCamera m_vCamRZ;

    /// <summary>
    /// Tigger enter de la zone à zoomer avec le changement de priorité à 3 pour avoir la priorité
    /// </summary>
    /// <param name="p_other">Collider du joueur entrant dans la zone</param>
    private void OnTriggerEnter(Collider p_other)
    {
        Debug.Log("Ok");
        if (p_other.gameObject.TryGetComponent(out PlayerController charaScript))
        {
            Debug.Log(charaScript.m_chara);
            switch (charaScript.m_chara)
            {
                case Charas.Human :
                    m_vCamHZ.Priority = 3;
                    break;
                case Charas.Monster :
                    m_vCamMZ.Priority = 3;
                    break;
                case Charas.Robot :
                    m_vCamRZ.Priority = 3;
                    break;
            }   
        }
    }
    
    /// <summary>
    /// Tigger exit de la zone à zoomer avec le changement de priorité à 1 pour enlever la priorité
    /// </summary>
    /// <param name="p_other">Collider du joueur entrant dans la zone</param>
    private void OnTriggerExit(Collider p_other)
    {
        Debug.Log("Ko");
        if (p_other.gameObject.TryGetComponent(out PlayerController charaScript))
        {
            Debug.Log(charaScript.m_chara);
            switch (charaScript.m_chara)
            {
                case Charas.Human :
                    m_vCamHZ.Priority = 1;
                    break;
                case Charas.Monster :
                    m_vCamMZ.Priority = 1;
                    break;
                case Charas.Robot :
                    m_vCamRZ.Priority = 1;
                    break;
            }   
        }
    }
    
}
