using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

/// <summary>
/// Script du mouvement du player controller
/// Possible amelioration : Empecher l'auto-ajustement de la rotation du joueur lié au Quaternion
/// </summary>
public class PlayerController : MonoBehaviour
{
    [Header("Player Controller")]
    
    [SerializeField] [Tooltip("Vitesse du joueur")] public float m_speed = 5f;
    [SerializeField] [Tooltip("Vitesse de Rotation du Quaternion")] private float m_rotationSpeed = 700f;
    [SerializeField] [Tooltip("The input used to select this character")] private SOInputMultiChara m_selector = null;
    [SerializeField] [Tooltip("The character whom this script is on, SELECT ONLY ONE !")] public Charas m_chara = 0;
    [HideInInspector] public KeyCode[] m_keyCodes = new[] {KeyCode.Joystick1Button0, KeyCode.Joystick1Button3, KeyCode.Joystick1Button1};
    [Tooltip("For Debug Only")] public bool m_isActive = false;
    private static bool s_inBetweenSwitching = false; //is Active when someone is switching character
    
    [Tooltip("For Debug Only")] public bool m_isForbiddenToMove = false; 
    [Tooltip("For Debug Only")] public bool m_isSwitchingChara = false;
    
    [Header("Soul")]

    [SerializeField]
    [Tooltip("The prefab of what represents the soul, it will be driven from a character to another when a switch occurs")] private GameObject m_soulPrefab = null;
    
    [Header("Death Manager")]
    
    [SerializeField] [Range(0.2f, 5f)] [Tooltip("The time the player is allowed to stay in this death zone (unit : seconds)")] private float m_timeBeforeDying = 0.5f;
    private float m_deathCounter = 0.0f;
    private bool m_isDying = false;
    [HideInInspector] public Vector3 m_spawnPoint = Vector3.zero;

    //Cinemachine cameras des trois personnages
    [HideInInspector] private static CinemachineVirtualCamera m_vCamH;
    [HideInInspector] private static CinemachineVirtualCamera m_vCamM;
    [HideInInspector] private static CinemachineVirtualCamera m_vCamR;

    private void Start()
    {
        DeathManager.DeathDelegator += Death;

        //We create an array (because it's easier to manipulate) of all the inputs of the characters
        m_keyCodes[0] = m_selector.inputHuman;
        m_keyCodes[1] = m_selector.inputMonster;
        m_keyCodes[2] = m_selector.inputRobot;

        m_vCamH = GameObject.FindGameObjectWithTag("Camera Humain")?.GetComponent<CinemachineVirtualCamera>();
        m_vCamM = GameObject.FindGameObjectWithTag("Camera Monstre")?.GetComponent<CinemachineVirtualCamera>();
        m_vCamR = GameObject.FindGameObjectWithTag("Camera Robot")?.GetComponent<CinemachineVirtualCamera>();
        
        if (m_chara == Charas.Human) m_isActive = true;

        //We set the first spawnpoint at its original position
        m_spawnPoint = transform.position;

    #if UNITY_EDITOR
        if(m_vCamH == null) Debug.LogError("Aucune caméra avec le tag Camera Humain");
        if(m_vCamM == null) Debug.LogError("Aucune caméra avec le tag Camera Monstre");
        if(m_vCamR == null) Debug.LogError("Aucune caméra avec le tag Camera Robot");

        if (m_soulPrefab == null) {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO PUT A PREFAB FOR THE SOUL ! WHERE DID HE GOT HIS FAKE DIPLOMA ?!");
        }
        
        if (m_selector == null) {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO PUT THE SCRIPTABLE OBJECT FOR THE INPUTS !");
        }
    #endif
    }

    void Update()
    {

        // TODO technique a verifier dans le projet complet
        if (Time.timeScale == 0) return;
        
        //If the character is in a transition between two characters
        if (!m_isSwitchingChara) {
            
            //The character is not able to move if not selected
            if (m_isActive && !m_isForbiddenToMove) {
                float horizontalInput = Input.GetAxis("Horizontal");
                float verticalInput = Input.GetAxis("Vertical");
                
                Vector3 movementDirection = new Vector3(horizontalInput,  0, verticalInput);
                movementDirection.Normalize();
                        
                if(m_isActive) transform.Translate(movementDirection * (m_speed * Time.deltaTime), Space.World);
            
                //Utilisation du Quaternion pour permettre au player de toujours se déplacer dans l'angle où il regarde
                if (movementDirection != Vector3.zero)
                {
                    Quaternion toRotation = Quaternion.LookRotation(movementDirection, Vector3.up);
                    
                    transform.rotation = Quaternion.RotateTowards(transform.rotation, toRotation, m_rotationSpeed * Time.deltaTime);
                }
                
            }

            //We activate this chara if its corresponding input is pressed
            if (Input.GetKeyDown(m_keyCodes[(int)m_chara])) {
                if (!m_isActive && !s_inBetweenSwitching) {
                    
                    switch (m_chara) {
                        case Charas.Human:
                            m_vCamH.Priority = 2;
                            m_vCamM.Priority = 1;
                            m_vCamR.Priority = 0;
                            break;
                        case Charas.Monster:
                            m_vCamH.Priority = 1;
                            m_vCamM.Priority = 2;
                            m_vCamR.Priority = 0;
                            break;
                        case Charas.Robot:
                            m_vCamH.Priority = 0;
                            m_vCamM.Priority = 1;
                            m_vCamR.Priority = 2;
                            break;
                        default:
                            Debug.LogError("Incorrect parameter on m_chara");
                            break;
                    }
                    m_isSwitchingChara = true;
                    s_inBetweenSwitching = true;
                    StartCoroutine(SwitchTimer());
                    
                }
            }
            //If any other input corresponding to another character is pressed, we inactive this chara
            else if (Input.GetKeyDown(m_keyCodes[0]) || Input.GetKeyDown(m_keyCodes[1]) || Input.GetKeyDown(m_keyCodes[2])){
                //If this character was active, we create a soul and send it to the next selected character
                if (m_isActive) {
                    GameObject soul = Instantiate(m_soulPrefab, transform.position, transform.rotation);
                    if (Input.GetKeyDown(m_keyCodes[(int) Charas.Human]))
                        soul.GetComponent<AutoRotation>().m_target = m_vCamH.LookAt;
                    if (Input.GetKeyDown(m_keyCodes[(int) Charas.Monster]))
                        soul.GetComponent<AutoRotation>().m_target = m_vCamM.LookAt;
                    if (Input.GetKeyDown(m_keyCodes[(int) Charas.Robot]))
                        soul.GetComponent<AutoRotation>().m_target = m_vCamR.LookAt;
                }
                m_isActive = false;
            }
        }
        
        //If this character is in a death zone, we increase his death timer, if not, we decrease it
        if (!m_isDying && m_deathCounter > 0f) {
            m_deathCounter -= Time.deltaTime;
        }
        else if (m_isDying) {
            m_deathCounter += Time.deltaTime;
            if (m_deathCounter > m_timeBeforeDying) {
                //The line below means that if the delegator is NOT empty, we invoke it.
                DeathManager.DeathDelegator?.Invoke();
            }
        }
    }

    /// <summary>
    /// Wait for a duration that depends on the switch duration, once it is done waiting it make m_isSwitchingChara in true, allowing the player to move and switch characters again
    /// </summary>
    IEnumerator SwitchTimer() {
        yield return new WaitForSeconds(m_soulPrefab.GetComponent<AutoRotation>().m_duration / 1.2f);
        m_isActive = true;
        m_isSwitchingChara = false;
        s_inBetweenSwitching = false;
    }
    

    /// <summary>
    /// Is called every frame as long as something is triggering the hitbox
    /// It is detecting the trigger with every death zone to be able to kill itself if it stays too long in there
    /// </summary>
    /// <param name="p_other">The Collider of the object we're triggering with</param>
    private void OnTriggerEnter(Collider p_other)
    {
        //We can detect if it is a player or not by checking if it has a PlayerController script
        if (!p_other.gameObject.TryGetComponent(out DeathZone pScript)) return;
        m_isDying = true;
    }

    /// <summary>
    /// Just to stop running the timer, if there's any weird behavior it may come from here (signed
    /// </summary>
    /// <param name="p_other">The Collider of the object we're exit-triggering with</param>
    private void OnTriggerExit(Collider p_other) {
        if (p_other.gameObject.TryGetComponent(out DeathZone pScript)) {
            m_isDying = false;
        }
    }
    
    /// <summary>
    /// For safety, we reset a few values in case of death & respawn
    /// </summary>
    private void Death() {
        //Reset of all death-related values
        m_isDying = false;
        m_deathCounter = 0.0f;

        transform.position = m_spawnPoint;
    }


    /// <summary>
    /// Sets a new camera focusing this character, will focus only if this character is selected
    /// </summary>
    /// <param name="p_newCamera">The new camera you want to have focus from</param>
    public void SetNewCamera(CinemachineVirtualCamera p_newCamera)
    {
        int oldPriority = 0;
        switch (m_chara)
        {
            case Charas.Human:
                oldPriority = m_vCamH.Priority;
                m_vCamH.Priority = 0;
                m_vCamH = p_newCamera;
                m_vCamH.Priority = oldPriority;
                break;
            case Charas.Monster:
                oldPriority = m_vCamM.Priority;
                m_vCamM.Priority = 0;
                m_vCamM = p_newCamera;
                m_vCamM.Priority = oldPriority;
                break;
            case Charas.Robot:
                oldPriority = m_vCamR.Priority;
                m_vCamR.Priority = 0;
                m_vCamR = p_newCamera;
                m_vCamR.Priority = oldPriority;
                break;
        }
    }

    /// <summary>
    /// Returns the camera focusing this character
    /// </summary>
    /// <returns>Returns the camera focusing this character</returns>
    public CinemachineVirtualCamera GetCurrentCamera()
    {
        switch (m_chara)
        {
            case Charas.Human:
                return m_vCamH;
            case Charas.Monster:
                return m_vCamM;
            case Charas.Robot:
                return m_vCamR;
            default:
                return null;
        }
    }
}