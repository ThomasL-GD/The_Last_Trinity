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
    [SerializeField] [Tooltip("The input used to select this character")] public SOInputMultiChara m_selector = null;
    [SerializeField] [Tooltip("The character whom this script is on, SELECT ONLY ONE !")] public Charas m_chara = 0;
    [HideInInspector] public KeyCode[] m_keyCodes = new[] {KeyCode.Joystick1Button0, KeyCode.Joystick1Button3, KeyCode.Joystick1Button1};
    [Tooltip("For Debug Only")] public bool m_isActive = false;
    private static bool s_inBetweenSwitching = false; //is Active when someone is switching character

    private CharacterController m_charaController = null;
    [SerializeField] [Tooltip("Gravity strength on this character")] private float m_gravity = -9.81f;
    private Vector3 m_charaVelocity = Vector3.zero;
    private Animator m_animator = null;
    
    [Tooltip("For Debug Only")] public bool m_isForbiddenToMove = false; 
    [Tooltip("For Debug Only")] public bool m_isSwitchingChara = false;
    
    [Header("Soul")]

    [SerializeField] [Tooltip("The game object of what represents the soul, it will be driven from a character to another when a switch occurs")] public GameObject m_soul = null;
    [Tooltip("Offset for the instantiate of the Soul")][SerializeField] public Vector3 m_soulOffset = Vector3.zero;
    private AutoRotation m_soulScript = null;
    
    [Header("Death Manager")]
    
    [SerializeField] [Range(0.2f, 5f)] [Tooltip("The time the player is allowed to stay in this death zone (unit : seconds)")] private float m_timeBeforeDying = 0.5f;
    [SerializeField] [Range(0.2f, 5f)] [Tooltip("The time of the death animation (must be longer than the death animation time) (unit : seconds)")] private float m_deathAnimTime = 1.5f;
    private float m_deathCounter = 0.0f;
    private bool m_isDying = false; //If the chara is in a death zone
    private bool m_isPlayingDead = false; //If the chara is currently playing their death animation
    [HideInInspector] public Vector3 m_spawnPoint = Vector3.zero;

    //Cinemachine cameras des trois personnages
    [HideInInspector] private static CinemachineVirtualCamera m_vCamH;
    [HideInInspector] private static CinemachineVirtualCamera m_vCamM;
    [HideInInspector] private static CinemachineVirtualCamera m_vCamR;
    private static readonly int IsRunning = Animator.StringToHash("isRunning");
    private static readonly int Death1 = Animator.StringToHash("Death");
    private static readonly int IsSneaky = Animator.StringToHash("IsSneaky");
    private static readonly int IsIntimidating = Animator.StringToHash("IsIntimidating");

    //Those lines are now useless due to the project Settings > Physics > Layers parameters
    // private void Awake()
    // {
    //     Physics.IgnoreLayerCollision(6,6); //Is supposed to forbid the collision between two players
    // }

    private void Start()
    {
        DeathManager.DeathDelegator += EndDeath;

        //We create an array (because it's easier to manipulate) of all the inputs of the characters
        m_keyCodes[0] = m_selector.inputHuman;
        m_keyCodes[1] = m_selector.inputMonster;
        m_keyCodes[2] = m_selector.inputRobot;

        m_vCamH = GameObject.FindGameObjectWithTag("Camera Humain")?.GetComponent<CinemachineVirtualCamera>();
        m_vCamM = GameObject.FindGameObjectWithTag("Camera Monstre")?.GetComponent<CinemachineVirtualCamera>();
        m_vCamR = GameObject.FindGameObjectWithTag("Camera Robot")?.GetComponent<CinemachineVirtualCamera>();


        //We set the first spawnpoint at its original position
        m_spawnPoint = transform.position;

    #if UNITY_EDITOR
        if(m_vCamH == null) Debug.LogError("Aucune caméra avec le tag Camera Humain");
        if(m_vCamM == null) Debug.LogError("Aucune caméra avec le tag Camera Monstre");
        if(m_vCamR == null) Debug.LogError("Aucune caméra avec le tag Camera Robot");

        if (m_soul == null) {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO PUT A PREFAB FOR THE SOUL ! WHERE DID HE GOT HIS FAKE DIPLOMA ?!");
        }
        
        if (m_selector == null) {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO PUT THE SCRIPTABLE OBJECT FOR THE INPUTS !");
        }
    #endif

        if (TryGetComponent(out Animator animator)) m_animator = animator;
        else Debug.LogWarning("JEEZ ! THE GAME DESIGNER FORGOT TO PUT AN ANIMATOR ON THIS CHARA ! (it's still gonna work tought)");
        
        if (TryGetComponent(out CharacterController charaController)) m_charaController = charaController;
        else Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO PUT A CHARA CONTROLLER ON THIS CHARA !");

        m_soulScript = m_soul.GetComponent<AutoRotation>();
        
        if (m_chara == Charas.Human) {
            m_isActive = true;
            m_soulScript.gameObject.transform.position = transform.position;
        }
    }

    void Update()
    {

        // TODO technique a verifier dans le projet complet
        if (Time.timeScale == 0) return;
        
        //Gravity with Character Controller
        if (m_charaController.isGrounded) {
            m_charaVelocity.y = 0.0f;
        }
        else if (!m_charaController.isGrounded) {
            m_charaVelocity.y += m_gravity * Time.deltaTime;
            m_charaController.Move(m_charaVelocity * Time.deltaTime);
        }
        //Debug.Log(m_charaController.isGrounded);
        
        //If the character is not in a transition between two characters
        if (!m_isSwitchingChara) {
            
            //The character is not able to move if not selected
            if (m_isActive && !m_isForbiddenToMove) {
                float horizontalInput = Input.GetAxis("Horizontal");
                float verticalInput = Input.GetAxis("Vertical");
                
                Vector3 movementDirection = new Vector3(horizontalInput,  0, verticalInput);
                movementDirection.Normalize();
                
                //The line below doesn't work with the charController component
                //if(m_isActive) transform.Translate(movementDirection * (m_speed * Time.deltaTime), Space.World);

                if (m_isActive) m_charaController.Move(movementDirection * (m_speed * Time.deltaTime));
            
                //Utilisation du Quaternion pour permettre au player de toujours se déplacer dans l'angle où il regarde
                if (movementDirection != Vector3.zero)
                {
                    Quaternion toRotation = Quaternion.LookRotation(movementDirection, Vector3.up);
                    
                    transform.rotation = Quaternion.RotateTowards(transform.rotation, toRotation, m_rotationSpeed * Time.deltaTime);
                    
                    if(m_animator != null) m_animator.SetBool("IsRunning", true);
                }
                else if(m_animator != null) m_animator.SetBool("IsRunning", false);

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
                    m_soulScript.gameObject.transform.position = transform.position + m_soulOffset;
                    if (Input.GetKeyDown(m_keyCodes[(int) Charas.Human])) {
                        m_soulScript.m_target = m_vCamH.LookAt;
                        m_soulScript.m_offsetTarget = m_vCamH.LookAt.gameObject.GetComponent<PlayerController>().m_soulOffset;
                    }
                    if (Input.GetKeyDown(m_keyCodes[(int) Charas.Monster])) {
                        m_soulScript.m_target = m_vCamM.LookAt;
                        m_soulScript.m_offsetTarget = m_vCamM.LookAt.gameObject.GetComponent<PlayerController>().m_soulOffset;
                    }
                    if (Input.GetKeyDown(m_keyCodes[(int) Charas.Robot])) {
                        m_soulScript.m_target = m_vCamR.LookAt;
                        m_soulScript.m_offsetTarget = m_vCamR.LookAt.gameObject.GetComponent<PlayerController>().m_soulOffset;
                    }
                }
                m_isActive = false;
            }
        }
        
        if(m_animator != null && (m_isForbiddenToMove || m_isSwitchingChara || !m_isActive)) m_animator.SetBool("IsRunning", false);
        
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
        
        //if(m_chara == Charas.Robot)Debug.Log($"{transform.position}");
    }

    /// <summary>
    /// Wait for a duration that depends on the switch duration, once it is done waiting it make m_isSwitchingChara in true, allowing the player to move and switch characters again
    /// </summary>
    IEnumerator SwitchTimer() {
        yield return new WaitForSeconds(m_soul.GetComponent<AutoRotation>().m_duration / 1.2f);
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
    
    /// <summary>
    /// Make the current camera look to another object
    /// </summary>
    /// <param name="p_newCamera">The new camera you want to have focus from</param>
    public void LookSomewhere(Transform p_lookAt)
    {
        switch (m_chara)
        {
            case Charas.Human:
                m_vCamH.LookAt = p_lookAt;
                break;
            case Charas.Monster:
                m_vCamM.LookAt = p_lookAt;
                break;
            case Charas.Robot:
                m_vCamR.LookAt = p_lookAt;
                break;
        }
    }
    
    /// <summary>
    /// Make the current camera look back to the current character
    /// </summary>
    public void Refocus()
    {
        switch (m_chara)
        {
            case Charas.Human:
                m_vCamH.LookAt = gameObject.transform;
                break;
            case Charas.Monster:
                m_vCamM.LookAt = gameObject.transform;
                break;
            case Charas.Robot:
                m_vCamR.LookAt = gameObject.transform;
                break;
        }
    }

    /// <summary>
    /// Function called to let the player the time to play its death animation
    /// </summary>
    public void Death() {
        if (!m_isPlayingDead) {
            DeathAnim(true);
            m_isForbiddenToMove = true;
            StartCoroutine(DeathTimer());
        }
        else Debug.LogWarning("Multiple Deaths at the same time ? this is hella shady");
    }
    
    /// <summary>
    /// Is called by the Death() function to wait for the animation to play before respawning
    /// </summary>
    /// <returns></returns>
    IEnumerator DeathTimer() {
        yield return new WaitForSeconds(m_deathAnimTime);
        DeathManager.DeathDelegator();
    }
    
    /// <summary>
    /// For safety, we reset a few values in case of death & respawn
    /// </summary>
    private void EndDeath() {
        //Reset of all death-related values
        m_isDying = false;
        m_deathCounter = 0.0f;
        m_isForbiddenToMove = false;

        transform.SetPositionAndRotation(m_spawnPoint, transform.rotation);
        if (m_chara == Charas.Robot) {
            //Debug.Log($"WELP : {m_spawnPoint}");
            //Debug.Log($"Welp (suite) : {transform.position}");
        }
        GuardBehavior.m_isKillingSomeone = false;
        DeathAnim(false);
    }

    /// <summary>
    /// A Function to play the death animation and make sure this character can't move during their animation
    /// </summary>
    private void DeathAnim(bool p_isOn) {
        if(m_animator != null) m_animator.SetBool("IsDead", p_isOn);
        m_isPlayingDead = p_isOn;
    }

    /// <summary>
    /// A public function to let other scripts start the ability animation of this character
    /// </summary>
    public void AbilityAnim(bool p_isTrue) {
        if (m_animator != null) {
            switch (m_chara) {
                case Charas.Human:
                    m_animator.SetBool("IsSneaky", p_isTrue);
                    break;
                case Charas.Monster:
                    m_animator.SetBool("IsIntimidating", p_isTrue);
                    break;
                case Charas.Robot:
                    m_animator.SetBool("IsTelekinesing", p_isTrue);
                    break;
            }
        }
    }
}