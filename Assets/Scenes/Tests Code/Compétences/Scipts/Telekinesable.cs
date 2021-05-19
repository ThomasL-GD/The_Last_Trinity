using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;
using UnityEngine.VFX;

public class Telekinesable : MonoBehaviour
{
    [Header("Inputs")]
    [SerializeField] [Tooltip("The input used to select this character")] private SOInputMultiChara m_selector = null;
    
    private bool m_telekinesieOpen = false; //Possibilité d'activer la télékinésie avec la touche de compétence du Robot
    private bool m_activeTelekinesie = false; //Télékinésie en Activation
    private bool m_isInBetweenTravel = false; //Caisse est en mouvement

    private Vector3 m_originalPos; //Position originale de la caisse au Start
    private Vector3 m_targetPos; //Position Résultante arpès le déplacement et le clamping
    
    [Header("Téléknésie")]
    [SerializeField] [Tooltip("Time of Travel")] [Range(0.1f, 3f)] private float m_smoothTime = 1f; //Temps pour que la caisse atteigne son point d'arrivé
    [SerializeField] [Tooltip("Height of Travel")] [Range(1f, 30f)] private float m_teleVal = 10f; //Hauteur de la Télékinésie
    
    [Header("Clamping")]
    [SerializeField] [Tooltip("Un slider d'int")] [Range(0, 4)] private int m_unSliderDint = 2;
    //[SerializeField] [Tooltip("The maximum authorized difference between the position to reach and the current position (unit : Unity meters)")] [Range(0f, 1f)] private float m_uncertainty = 0.1f;
   
    private Vector3 m_velocity = Vector3.zero; //Vélocité 0 pour le smoothDamp
    private PlayerController m_robotScript = null; //Récupération du script du plauerController pour obtenir le Robot

    private VisualEffect m_cube; //Visual effect en enfant de l'objet Telekinesable
    
    void Start()
    {
        m_originalPos = transform.position;
        // Define a target position above the object transform
        m_targetPos = new Vector3(m_originalPos.x, m_originalPos.y + m_teleVal, m_originalPos.z);

        if (m_selector == null)
        {
            Debug.LogError("Manque le scriptable object d'input");
        }
        
        m_cube = GetComponentInChildren<VisualEffect>();
        m_cube.Stop();
        
        if (m_cube == null)
        {
            Debug.LogError("Manque l'effet sur le cube telekinesable");
        }
    }
    
    private void Update()
    {
        Vector3 posClamp = ClampEnjoyer(transform.position);
        
        if (posClamp == ClampEnjoyer(m_originalPos) && !m_activeTelekinesie)
        {
            m_isInBetweenTravel = false;
            m_activeTelekinesie = true;
            if(m_telekinesieOpen) m_robotScript.m_isForbiddenToMove = false;
        }
        else if (posClamp == ClampEnjoyer(m_targetPos) && m_activeTelekinesie)
        {
            //Debug.Log("Quelconque");
            m_isInBetweenTravel = false;
            m_activeTelekinesie = false;
        }
        
        //Stop l'effet des cubes
        //m_cube.Stop();
        
        if (m_telekinesieOpen)
        {
            if (Input.GetKeyDown(m_selector.inputRobot) && !m_isInBetweenTravel && m_robotScript.m_isActive)
            {
                m_isInBetweenTravel = true;
                if (m_activeTelekinesie) m_robotScript.m_isForbiddenToMove = true;
            }
        }
        
        if (m_activeTelekinesie && m_isInBetweenTravel)
        {
            transform.position = Vector3.SmoothDamp(transform.position, m_targetPos, ref m_velocity, m_smoothTime);
        } else if (!m_activeTelekinesie && m_isInBetweenTravel)
        {
            transform.position = Vector3.SmoothDamp(transform.position, m_originalPos, ref m_velocity, m_smoothTime);
        }
    }

    /// <summary>
    /// Permet au joueur (p_other) d'activer la télékinésie qu'à l'entrée de la zone
    /// </summary>
    /// <param name="p_other"></param>
    private void OnTriggerEnter(Collider p_other)
    {
        if (p_other.gameObject.TryGetComponent(out PlayerController player))
        {
            if (player.m_chara == Charas.Robot)
            {
                m_cube.Play();
                m_telekinesieOpen = true;
                m_robotScript = player;
            }
        }
    }
    
    /// <summary>
    /// Désactive la possibilité de pouvoir utiliser la télékinésie à la sortie de la zone
    /// </summary>
    /// <param name="p_other"></param>
    private void OnTriggerExit(Collider p_other)
    {
        if (p_other.gameObject.TryGetComponent(out PlayerController player))
        {
            if (player.m_chara == Charas.Robot)
            {
                m_cube.Stop();
                m_telekinesieOpen = false;
                m_activeTelekinesie = false;
                m_robotScript = null;
                //Debug.Log(m_telekinesieOpen);
            }
        }
    }

    /// <summary>
    /// Permet de clamper la position d'un Vector3 (p_pos) pour éviter qu'elle ne décroisse indéfiniment après le SmoothDamp
    /// </summary>
    /// <param name="p_pos"></param>
    /// <returns></returns>
    private Vector3 ClampEnjoyer(Vector3 p_pos)
    {
        float pow = Mathf.Pow(10, m_unSliderDint);
        return new Vector3(Mathf.Round((p_pos.x * pow)/pow), Mathf.Round((p_pos.y * pow)/pow), Mathf.Round((p_pos.z * pow)/pow));
    }
}
