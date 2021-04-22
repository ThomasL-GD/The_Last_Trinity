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

    [SerializeField] [Tooltip("Vitesse du joueur")] private float m_speed = 5f;
    [SerializeField] [Tooltip("Vitesse de Rotation du Quaternion")] private float m_rotationSpeed = 700f;
    [SerializeField] [Tooltip("The input used to select this character")] private SOInputMultiChara m_selector = null;
    [SerializeField] [Tooltip("The character whom this script is on, SELECT ONLY ONE !")] public Charas m_chara = 0;
    private KeyCode[] m_keyCodes = new[] {KeyCode.Joystick1Button0, KeyCode.Joystick1Button3, KeyCode.Joystick1Button1};
    private bool m_isActive = false;
    private bool m_isSwitchingChara = false;

    [SerializeField]
    [Tooltip("The prefab of what represents the soul, it will be driven from a character to another when a switch occurs")] private GameObject m_soul = null;
    
    [SerializeField] [Range(0.2f, 5f)] [Tooltip("The time the player is allowed to stay in this death zone (unit : seconds)")] private float m_timeBeforeDying = 0.5f;
    private float m_deathCounter = 0.0f;
    private bool m_isDying = false;

    [SerializeField] private CinemachineVirtualCamera m_vCamH;
    [SerializeField] private CinemachineVirtualCamera m_vCamM;
    [SerializeField] private CinemachineVirtualCamera m_vCamR;

    private void Start()
    {
        DeathManager.DeathDelegator += ResetValues;

        //We create an array (because it's easier to manipulate) of all the inputs of the characters
        m_keyCodes[0] = m_selector.inputHuman;
        m_keyCodes[1] = m_selector.inputMonster;
        m_keyCodes[2] = m_selector.inputRobot;

        if (m_chara == Charas.Human) m_isActive = true;

        if (m_soul == null) {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO PUT A PREFAB FOR THE SOUL ! WHERE DID HE GOT HIS FAKE DIPLOMA ?!");
        }
        
        if (m_selector == null) {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO PUT THE SCRIPTABLE OBJECT FOR THE INPUTS !");
        }
    }

    void Update()
    {

        //If the character is in a transition between two characters
        if (!m_isSwitchingChara) {
            
            //The character is not able to move if not selected
            if (m_isActive) {
                float horizontalInput = Input.GetAxis("Horizontal");
                float verticalInput = Input.GetAxis("Vertical");
                
                Vector3 movementDirection = new Vector3(horizontalInput,  0, verticalInput);
                movementDirection.Normalize();
                        
                if(m_isActive) transform.Translate(movementDirection * m_speed * Time.deltaTime, Space.World);
            
                //Utilisation du Quaternion pour permettre au player de toujours se déplacer dans l'angle où il regarde
                if (movementDirection != Vector3.zero)
                {
                    Quaternion toRotation = Quaternion.LookRotation(movementDirection, Vector3.up);
                    
                    transform.rotation = Quaternion.RotateTowards(transform.rotation, toRotation, m_rotationSpeed * Time.deltaTime);
                }
                
            }

            //We activate this chara if its corresponding input is pressed
            if (Input.GetKeyDown(m_keyCodes[(int)m_chara]))
            {
                switch (m_chara)
                {
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
                }
                
                m_isSwitchingChara = true;
                StartCoroutine(SwitchTimer());
                
                m_isActive = true;
            }
            //If any other input corresponding to another character is pressed, we inactive this chara
            else if (Input.GetKeyDown(m_keyCodes[0]) || Input.GetKeyDown(m_keyCodes[1]) || Input.GetKeyDown(m_keyCodes[2])){
                //If this character was active, we create a soul and send it to the next selected character
                if (m_isActive) {
                    GameObject soul = Instantiate(m_soul, transform.position, transform.rotation);
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
        }
    }

    /// <summary>
    /// Wait for a duration that depends on the switch duration, once it is done waiting it make m_isSwitchingChara in true, allowing the player to move and switch characters again
    /// </summary>
    IEnumerator SwitchTimer() {
        yield return new WaitForSeconds(m_soul.GetComponent<AutoRotation>().m_duration / 1.2f);
        m_isSwitchingChara = false;
    }
    

    /// <summary>
    /// Is called every frame as long as something is triggering the hitbox
    /// It is detecting the trigger with every death zone to be able to kill itself if it stays too long in there
    /// </summary>
    /// <param name="p_other">The Collider of the object we're triggering with</param>
    private void OnTriggerStay(Collider p_other) {
        //We can detect if it is a player or not by checking if it has a PlayerController script
        if (p_other.gameObject.TryGetComponent(out DeathZone pScript)) {
            m_isDying = true;
            if (m_deathCounter > m_timeBeforeDying) {
                //The line below means that if the delegator is NOT empty, we invoke it.
                DeathManager.DeathDelegator?.Invoke();
            }
        }
        
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
    private void ResetValues() {
        m_isDying = false;
        m_deathCounter = 0.0f;
    }
}
