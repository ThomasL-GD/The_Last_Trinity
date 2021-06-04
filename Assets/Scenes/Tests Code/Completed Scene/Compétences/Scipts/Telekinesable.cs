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
    [SerializeField] [Tooltip("The gameobject that will be active when the robot is close enough")] private GameObject m_teleportFeedback = null;
    //[SerializeField] [Tooltip("The maximum authorized difference between the position to reach and the current position (unit : Unity meters)")] [Range(0f, 1f)] private float m_uncertainty = 0.1f;
   
    private Vector3 m_velocity = Vector3.zero; //Vélocité 0 pour le smoothDamp
    private PlayerController m_robotScript = null; //Récupération du script du plauerController pour obtenir le Robot

    private VisualEffect m_cube; //Visual effect en enfant de l'objet Telekinesable
    
    // [Header("Audio")]
    // [SerializeField] [Tooltip("Son de montée")] private AudioSource m_upSound;
    // [SerializeField] [Tooltip("Son de stabilisation")] private AudioSource m_telekinesieSound;
    // [SerializeField] [Tooltip("Son de descente")] private AudioSource m_downSound;
    
    void Start() {
        DeathManager.DeathDelegator += Reset;
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
            //son de télékinésie stable
            //m_telekinesieSound.PlayOneShot(m_telekinesieSound.clip);
            
            //Debug.Log("Quelconque");
            m_isInBetweenTravel = false;
            m_activeTelekinesie = false;
        }

        if (m_telekinesieOpen)
        {
            bool selectorValidation = false;
            if(!m_robotScript.m_cycle) selectorValidation = Input.GetKeyDown(m_selector.inputRobot);
            else if(m_robotScript.m_cycle) selectorValidation = Rumbler.Instance.m_gamepad.buttonSouth.wasPressedThisFrame;
            
            if (selectorValidation && !m_isInBetweenTravel && m_robotScript.m_isActive)
            {

                m_isInBetweenTravel = true;
                m_velocity = Vector3.zero;
                if (m_activeTelekinesie)
                {
                    m_robotScript.m_isForbiddenToMove = true;
                    //m_upSound.PlayOneShot(m_upSound.clip); //son de montée
                    m_robotScript.AbilityAnim(true); //Animation up play
                }
                else{
                    m_robotScript.AbilityAnim(false); //Animation down play
                    //m_downSound.PlayOneShot(m_downSound.clip);  //son de descente
                }
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
                if(m_teleportFeedback != null) m_teleportFeedback.SetActive(true);
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
                if(m_teleportFeedback != null) m_teleportFeedback.SetActive(false);
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

    public void Reset() {
        transform.position = m_originalPos;
        m_cube.Stop();
        m_telekinesieOpen = false;
        m_activeTelekinesie = false;
        if (m_robotScript != null) m_robotScript.AbilityAnim(false);
        m_robotScript = null;
        m_isInBetweenTravel = false;
    }
}
