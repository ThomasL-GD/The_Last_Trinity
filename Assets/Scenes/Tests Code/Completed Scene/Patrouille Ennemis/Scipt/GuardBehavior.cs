using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.DualShock;

[RequireComponent(typeof(SphereCollider))]
public class GuardBehavior : MonoBehaviour {

    //Collider présent sur notre ennemi
    private SphereCollider m_sphereCol = null;
    private Animator m_animator = null;

    //variables d'IA
    [HideInInspector] public NavMeshAgent m_nma = null;
    private int m_currentDestination = 0;

    [Header("Behavior")]
    [SerializeField]
    [Tooltip("If on, this ennemy will stay in place according to its initial position")] private bool m_isStatic = false;
    private Vector3 m_staticPos = Vector3.zero;
    private Quaternion m_staticRotation = new Quaternion(0,0,0,0);
    //private bool m_isOnTheirSpot = true;

    [Header("Metrics")] 
    [SerializeField] [Tooltip("Vitesse de déplacement normale")] [Range(0f,50f)] private float m_normalSpeed = 5.0f;
    [SerializeField] [Tooltip("Vitesse de déplacement aggressive")] [Range(0f,50f)] private float m_attackSpeed = 15.0f;
    [SerializeField] [Tooltip("Vitesse d'accélération normale")] [Range(0f,50f)] private float m_normalAcceleration = 5.0f;
    [SerializeField] [Tooltip("Vitesse d'accélération aggressive")] [Range(0f,50f)] private float m_attackAcceleration = 15.0f;
    [SerializeField] [Tooltip("Vitesse de rotation normale")] [Range(0f,10000f)] private float m_normalRotationSpeed = 300.0f;
    [SerializeField] [Tooltip("Vitesse de rotation aggressive")] [Range(0f,10000f)] private float m_attackRotationSpeed = 900.0f;

    [Header("SphereManager")]
    [SerializeField] [Tooltip("The radius of the detection area")] [Range(0.01f,10f)] private float m_sphereRadius = 2.0f;
    [SerializeField] [Tooltip("The possible angle of detection")] [Range(0.1f,180f)] private float m_angleUncertainty = 9.0f;
    [SerializeField] [Tooltip("The maximum authorized difference between the position to reach and the current position (unit : Unity meters)")] [Range(0.0001f,1f)] private float m_uncertainty = 0.1f;
    [SerializeField] [Tooltip("Changement position en hauteur de rayon pour raycast")] [Range(0.01f,50f)] private float m_offsetRay = 2.0f;
    
    [Header("Waypoints Manager")]
    [SerializeField] [Tooltip("The list of points the guard will travel to, in order from up to down and cycling")] private List<Transform> m_destinationsTransforms = new List<Transform>();
    private List<Vector3> m_destinations = new List<Vector3>();

    [Header("Death")]
    [SerializeField] [Tooltip("distance d'élimination")] [Range(0f,10f)] private float m_deathPos = 1.0f;
    [SerializeField] [Tooltip("temps d'animation de mort")] [Range(0f,10f)] private float m_deathTime = 3.0f;

    [SerializeField] [Tooltip("The gameobject of the hit FX, must be already placed in a good position and setActive(false)\nMust be a child of this object\nCan be null")] private GameObject m_hitFX = null;
    private Vector3 m_spawnPoint = Vector3.zero;
    
    [Header("Monster Ability")]
    [SerializeField] [Tooltip("Temps de déploiement de l'intimidation du monstre allié\nUnit : seconds")] [Range(0f,60f)] private float m_intimidationTime = 1.0f;
    [SerializeField] [Tooltip("Temps pendant lequel l'ennemi est stun\nMust be greater than intimidation Time\nUnit : seconds")] [Range(0f,180f)] private float m_stunTime = 1.0f;
    
    [Header("Rumble")]
    [SerializeField] [Tooltip("valeur de la vibration faible lorsque le character entre dans la zone de l'ennemi")] [Range(0f,1f)] private float m_lowWarningEnemy =0f;
    [SerializeField] [Tooltip("valeur de la vibration forte lorsque le character entre dans la zone de l'ennemi")] [Range(0f,1f)] private float m_highWarningEnemy =0f;
    [SerializeField] [Tooltip("valeur de la vibration faible lorsque le character est visible par l'ennemi")] [Range(0f,1f)] private float m_lowAttackEnemy =0f;
    [SerializeField] [Tooltip("valeur de la vibration forte lorsque le character est visible par l'ennemi")] [Range(0f,1f)] private float m_highAttackEnemy =0f;
    [SerializeField] [Tooltip("valeur de la vibration faible lorsque le character monstre utilise sa compétence")] [Range(0f,1f)] private float m_lowMonsterIntimidation =0.5f;
    [SerializeField] [Tooltip("valeur de la vibration forte lorsque le character monstre utilise sa compétence")] [Range(0f,1f)] private float m_highMonsterIntimidation =0.5f;
    [SerializeField] [Tooltip("valeur de la vibration forte lorsque le character monstre utilise sa compétence")] [Range(0f,10f)] private float m_rumbleDuration =0.5f;
    
    [SerializeField] [Tooltip("For Debug Only")] bool m_warningVibe = false; //présence d'un character dans la zone de l'ennemi
    [SerializeField] [Tooltip("For Debug Only")] bool m_intimidationVibe = false;   //utilisation de la compétence du monstre dans la zone de l'ennemi
    [SerializeField] [Tooltip("For Debug Only")] bool m_attackVibe = false;   //attack de l'ennemi sur un character


    [SerializeField] [Tooltip("For Debug Only")] private bool m_enterZone = false;
    private bool m_hasSeenPlayer = false;
    private bool m_isGoingTowardsPlayer = false;
    public static bool m_isKillingSomeone = false;  //tous les script de l'ennemi possèdent la même valeur de la variable au même moment
    [Tooltip("For Debug Only")] private List<PlayerController> m_charactersInDangerScript = new List<PlayerController>(); //Liste des scripts sur les character qui entrent et sortent de la zone de l'ennemi


    private static readonly int IsStun = Animator.StringToHash("IsStun");
    private static readonly int IsChasing = Animator.StringToHash("IsChasing");
    private static readonly int IsWalking = Animator.StringToHash("IsWalking");

    // [Header("Audio")] 
    //[SerializeField] [Tooltip("déplacement Monstre")] private AudioSource m_moveSound;
    // [SerializeField] [Tooltip("attaque Monstre")] private AudioSource m_attackSound;
    // [SerializeField] [Tooltip("detection Monstre")] private AudioSource m_detectionSound;
    // [SerializeField] [Tooltip("poursuite Monstre")] private AudioSource m_pursuitSound;
    // [SerializeField] [Tooltip("respiration Monstre")] private AudioSource m_breathSound;
    // [SerializeField] [Tooltip("Intimidation")] private AudioSource m_intimidationSound;

    public AudioSource[] m_audioSource;
    
    // Start is called before the first frame update
    void Start() {
        
        m_audioSource = GetComponents<AudioSource>();
        
        if(m_destinationsTransforms.Count < 1) Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO PUT DESTINATIONS IN THE ENNEMY !", this);
        
        if(m_hitFX == null) Debug.LogWarning("There's no FX for the hit of this ennemy, it's still gonna work thought", this);

        //We adapt the collider to the Serialized value we have
        m_sphereCol = gameObject.GetComponent<SphereCollider>();
        m_sphereCol.radius = m_sphereRadius;
        m_sphereCol.isTrigger = true;

        m_animator = GetComponent<Animator>();

        m_nma = gameObject.GetComponent<NavMeshAgent>();

        if (m_isStatic) {
            //If the ennemy is static, we stock its position and rotation
            Transform transform1 = transform;
            m_staticPos = transform1.position;
            m_staticRotation = transform1.rotation;
            if(m_animator != null)m_animator.SetBool(IsWalking, false);
        }
        else {
            if(m_animator != null)m_animator.SetBool(IsWalking, true);
            //We transform the list of Transforms (easier to serialize) into a list of Vector3 (easier to manipulate)
            for (int i = 0; i < m_destinationsTransforms.Count; i++) {
                m_destinations.Add(m_destinationsTransforms[i].position);
            }

            m_nma.speed = m_normalSpeed;

            //The first position where the guard will aim at
            m_nma.SetDestination(m_destinations[m_currentDestination]);
        }
    }

    private void OnEnable() {
        m_spawnPoint = transform.position;
        DeathManager.DeathDelegator += Death;
    }

    private void OnDisable() {
        DeathManager.DeathDelegator -= Death;
    }


    private Coroutine m_intimidationCor = null;
    private static readonly int Attack = Animator.StringToHash("Attack");


    // Update is called once per frame
    void Update() {

        if (!m_isKillingSomeone) {
            if(!m_isStatic){
                if (m_animator != null) {
                    m_animator.SetBool(IsWalking, true);
                    //m_moveSound.Play(); //son de déplacement d'un monstre
                }
                //If the guard is close enough to the point he was trying to reach
                if (transform.position.x <= m_destinations[m_currentDestination].x + m_uncertainty &&
                    transform.position.x >= m_destinations[m_currentDestination].x - m_uncertainty &&
                    transform.position.z <= m_destinations[m_currentDestination].z + m_uncertainty &&
                    transform.position.z >= m_destinations[m_currentDestination].z - m_uncertainty) {

                    //if he was off his initial path we simply put him back on
                    if (m_isGoingTowardsPlayer) {
                        m_isGoingTowardsPlayer = false;
                        m_destinations.Remove(m_destinations[m_currentDestination]);
                        m_nma.SetDestination(m_destinations[m_currentDestination]);
                    }
                    //If he reached a point on his initial path, the guard will aim at the next one
                    else {
                        m_currentDestination++;
                        //If he reached the end of his path, we make him start over
                        if (m_currentDestination >= m_destinations.Count) m_currentDestination = 0;
                        m_nma.SetDestination(m_destinations[m_currentDestination]);
                    }
                }
            }
            else if (m_isStatic) {
                //If the guard is close enough to the point he was trying to reach
                if (transform.position.x <= m_staticPos.x + m_uncertainty &&
                    transform.position.x >= m_staticPos.x - m_uncertainty &&
                    transform.position.z <= m_staticPos.z + m_uncertainty &&
                    transform.position.z >= m_staticPos.z - m_uncertainty) {

                    //m_isOnTheirSpot = true;

                    if(m_animator != null)m_animator.SetBool(IsWalking, false);
                    
                    //Debug.Log($"enemy rotation {Mathf.Abs(Mathf.Abs(m_staticRotation.eulerAngles.y) - Mathf.Abs(transform.rotation.eulerAngles.y))}   warning : {!m_warningVibe}   attack : {!m_attackVibe}", this);

                    if (Mathf.Abs(Mathf.Abs(m_staticRotation.eulerAngles.y) - Mathf.Abs(transform.rotation.eulerAngles.y)) > 1f && (!m_warningVibe && !m_attackVibe)) {
                        float angle = Mathf.Abs(m_staticRotation.eulerAngles.y) - Mathf.Abs(transform.rotation.eulerAngles.y);
                        //Debug.Log($"Angle   :  {angle}", this);
                        if (angle > 0) m_nma.transform.Rotate(Vector3.up, m_normalRotationSpeed * Time.deltaTime);
                        else if (angle <= 0) m_nma.transform.Rotate(Vector3.up, -m_normalRotationSpeed * Time.deltaTime);
                        
                    }
                }
                else{
                    if (m_animator != null) {
                        m_animator.SetBool(IsWalking, true);
                        //m_moveSound.Play(); //Son de déplacement du personnage
                    }}
            }
        }
        

        if (m_enterZone && !m_isKillingSomeone && !m_intimidationVibe && !(m_charactersInDangerScript[0].m_chara == Charas.Human && m_charactersInDangerScript[0].m_isForbiddenToMove)) {
            m_warningVibe = true;
            m_intimidationVibe = false;
            m_attackVibe = false;


            //calcul de la position du premier chara entré dans la zone
            Vector3 targetDir = (m_charactersInDangerScript[0].gameObject.transform.position - transform.position).normalized;
            //angle de détection lorsque l'ennemi est à peu près en face du joueur
            float angleForward = Vector3.Angle(transform.forward, targetDir);
            

            //création de la variable du  raycast
            RaycastHit hit;
            
            //élévation de la position du raycast
            Vector3 raycastPosition = new Vector3(transform.position.x, transform.position.y + m_offsetRay, transform.position.z);
            
            //création physique du raycast
            bool raycastHasHit = Physics.Raycast(raycastPosition, targetDir, out hit, m_sphereRadius * 5);
            
            
            //Debug du raycast dans la scène
            if (raycastHasHit)
            {
                Debug.DrawRay(raycastPosition, targetDir * hit.distance, Color.magenta, 10f);
                //m_detectionSound.Play(); //Son de repérage d'un character
                
                if (m_charactersInDangerScript[0].gameObject.transform.position != hit.transform.position) //le chara se trouve derrière un obstacle et n'est pas visible par l'ennemi
                {
                    Debug.Log("Oulala on ne voit pas le character derrière");
                    
                    if (m_hasSeenPlayer) {
                        m_nma.speed = m_attackSpeed;
                        m_nma.acceleration = m_attackAcceleration;
                        m_nma.angularSpeed = m_attackRotationSpeed;
                    }
                    else {
                        m_nma.speed = m_normalSpeed;
                        m_nma.acceleration = m_normalAcceleration;
                        m_nma.angularSpeed = m_normalRotationSpeed;
                    }
                    
                }
                else //le chara est visible par l'ennemi
                {
                    
                    //Si le joueur est dans l'angle mort de l'ennemi
                    if (Mathf.Abs(angleForward) > m_angleUncertainty)
                    {
                        m_warningVibe = true;
                        m_intimidationVibe = false;
                        m_attackVibe = false;
                        
                        if (m_hasSeenPlayer)
                        {
                            m_nma.speed = m_attackSpeed;
                            m_nma.acceleration = m_attackAcceleration;
                            m_nma.angularSpeed = m_attackRotationSpeed;
                        }
                        else m_nma.speed = 0f;

                        //sens de rotation en fonction de la position du joueur qui est dans la zone mais pas encore repéré
                        float angleRight = Vector3.Angle(transform.right, targetDir);
                        if (Mathf.Abs(angleRight) < 90) m_nma.transform.Rotate(Vector3.up, m_normalRotationSpeed * Time.deltaTime);
                        else if (Mathf.Abs(angleRight) > 90) m_nma.transform.Rotate(Vector3.up, -m_normalRotationSpeed * Time.deltaTime);

                    }
                    //si le joueur est visible par l'ennemi
                    else if (angleForward <= m_angleUncertainty) {
                        
                        //m_pursuitSound.Play();  //Son de poursuite de character
                        //m_breathSound.Play();   //Son de respiration du monstre
                        
                        //if(m_isStatic)m_isOnTheirSpot = false;
                        m_warningVibe = false;
                        m_intimidationVibe = false;
                        m_attackVibe = true;

                        m_hasSeenPlayer = true;
                        CheckOutSomewhere(m_charactersInDangerScript[0].gameObject.transform.position);
                        m_nma.speed = m_attackSpeed;
                        m_nma.acceleration = m_attackAcceleration;
                        m_nma.angularSpeed = m_attackRotationSpeed;

                        //mort du joueur dès qu'il est assez proche
                        if (Vector3.Distance(m_charactersInDangerScript[0].transform.position, transform.position) < m_deathPos && !m_isKillingSomeone)
                        {
                            //Debug.Log($"J'AI TROUVE UNE VICTIME      :      {m_isKillingSomeone}");
                            //m_attackSound.Play();   //Son d'attaque du monstre
                            StartCoroutine(DeathCoroutine());
                        }
                    }
                }
            }
            else {
                
                //if he was off his initial path we simply put him back on
                if (m_isGoingTowardsPlayer && !m_isStatic) {
                    m_isGoingTowardsPlayer = false;
                    m_destinations.Remove(m_destinations[m_currentDestination]);
                    m_nma.SetDestination(m_destinations[m_currentDestination]);
                }
                
                //Debug.LogWarning("The raycast hit nothing nowhere");
                
                //if he was off his initial path we simply put him back on
                if (m_isGoingTowardsPlayer && m_isStatic) {
                    m_isGoingTowardsPlayer = false;
                    m_nma.SetDestination(m_staticPos);
                }
            }
            
                
            //INTIMIDATION DU MONSTRE
            bool selectorValidation = false;
            if(!m_charactersInDangerScript[0].m_cycle) selectorValidation = Input.GetKeyDown(m_charactersInDangerScript[0].m_selector.inputMonster);
            else if(m_charactersInDangerScript[0].m_cycle) selectorValidation = Rumbler.Instance.m_gamepad.buttonSouth.wasPressedThisFrame;
            
            if (selectorValidation && m_charactersInDangerScript[0].m_chara == Charas.Monster) // TODO monster in any index
            {
                m_warningVibe = false;
                m_intimidationVibe = true;
                m_attackVibe = false;
                if (m_intimidationCor == null) StartCoroutine(Intimidate());
            }


        }
        
        if(!m_enterZone) {
            m_warningVibe = false;
            m_intimidationVibe = false;
            m_attackVibe = false;
            
            //if he was off his initial path we simply put him back on
            if (m_isGoingTowardsPlayer && m_isStatic) {
                m_isGoingTowardsPlayer = false;
                m_nma.SetDestination(m_staticPos);
            }
            
            
            //if he was off his initial path we simply put him back on
            if (m_isGoingTowardsPlayer && !m_isStatic) {
                m_isGoingTowardsPlayer = false;
                m_destinations.Remove(m_destinations[m_currentDestination]);
                m_nma.SetDestination(m_destinations[m_currentDestination]);
            }
        }
        
        
        if (m_warningVibe && !m_intimidationVibe && !m_attackVibe && m_charactersInDangerScript.Count>0){
            //Vibration de détection proche
            Rumbler.Instance.Rumble(m_lowWarningEnemy, m_highWarningEnemy);
        }
        else if (m_intimidationVibe && !m_warningVibe && !m_attackVibe){
            //Vibration d'intimidation du monstre allié
            Rumbler.Instance.Rumble(m_lowMonsterIntimidation, m_highMonsterIntimidation);
        }
        else if (m_attackVibe && !m_warningVibe && !m_intimidationVibe){
            if(m_animator != null)m_animator.SetBool(IsChasing, true);
            //vibration d'attaque ennemie
            Rumbler.Instance.Rumble(m_lowAttackEnemy, m_highAttackEnemy);
        }
        else if (!m_warningVibe && !m_attackVibe && !m_intimidationVibe && !m_isKillingSomeone){
            if(m_animator != null)m_animator.SetBool(IsChasing, false);
            //arrêt de vibration
            //Debug.Log("Stop vibration !");
            //Rumbler.Instance.StopRumble();
        }
    }


    
    
    IEnumerator Intimidate()
    {

        //m_intimidationSound.Play(); //son d'intimidation du monstre allié
        
        //appel singleton vibe
        Rumbler.Instance.Rumble(m_lowMonsterIntimidation, m_highMonsterIntimidation, m_rumbleDuration);
        if(m_animator != null)m_animator.SetBool(IsStun, true);

        m_nma.isStopped = true;
        PlayerController scriptCharaWhoIsDying = m_charactersInDangerScript[0];
        scriptCharaWhoIsDying.m_isForbiddenToMove = true;
        scriptCharaWhoIsDying.AbilityAnim(true);
        
        yield return new WaitForSeconds(m_intimidationTime); //temps d'animation d'intimidation
        
        //arrêt de vibration
        Rumbler.Instance.StopRumble();
        
        scriptCharaWhoIsDying.m_isForbiddenToMove = false;
        scriptCharaWhoIsDying.AbilityAnim(false);
        StartCoroutine(Stun());
        m_intimidationCor = null;
    }
    IEnumerator Stun()
    {
        yield return new WaitForSeconds(m_stunTime); //durée de stun
        if(m_animator != null)m_animator.SetBool(IsStun, false);
        m_nma.isStopped = false;
        m_intimidationVibe = false;
    }
    IEnumerator DeathCoroutine()
    {
        m_isKillingSomeone = true;
        m_animator.SetTrigger(Attack);
        PlayerController scriptCharaWhoIsDying = m_charactersInDangerScript[0];
        m_nma.isStopped = true;
        scriptCharaWhoIsDying.m_isForbiddenToMove = true;
        yield return new WaitForSeconds(m_deathTime); //temps d'animation de mort du monstre
        
        m_hitFX.GetComponent<ParticleSystem>().Play();
        
        if(m_animator != null)m_animator.SetBool(IsChasing, false);
        if(m_animator != null)m_animator.SetBool(IsWalking, false);

        scriptCharaWhoIsDying.Death();  //mort   // We will reset m_isForbiddenToMove and m_isKillingSomeone in there
    }
    
    
    
    /// <summary>
    /// This function is called by the Delegator each time someone or something detect the player
    /// it is only called if m_isaPCGuard is true
    /// </summary>
    /// <param name="p_playerPos">The last detected position of the player</param>
    private void CheckOutSomewhere(Vector3 p_playerPos) {
        
        //If the guard was already off his path, we cancel his last destination
        if (m_isGoingTowardsPlayer) m_destinations.Remove(m_destinations[m_currentDestination]);
        
        //We make the guard go to the position of the player when he was seen
        m_isGoingTowardsPlayer = true;
        m_destinations.Insert(m_currentDestination, p_playerPos);
        m_nma.SetDestination(m_destinations[m_currentDestination]);
    }


    /// <summary>
    /// Called each frame as long as the collider is colliding a collider that is isTrigger
    /// </summary>
    /// <param name="p_other">The collider that we are colliding with</param>
    private void OnTriggerEnter(Collider p_other) {

        //If the thing we are colliding is a playable character and only him
        if (p_other.gameObject.TryGetComponent(out PlayerController charaScript))
        {
            bool isAlreadyInList = false;
            for(int i = 0; i<m_charactersInDangerScript.Count; i++) {
                if (m_charactersInDangerScript[i] == charaScript) {
                    isAlreadyInList = true;
                    i = m_charactersInDangerScript.Count;
                }
            }
            if(!isAlreadyInList) m_charactersInDangerScript.Add(charaScript);
            
            m_enterZone = true;
            Debug.Log("OnTriggerExit", this);
        }
    }
    
    
    /// <summary>
    /// Retour à vitesse normale dès qu'un character n'est plus trigger
    /// </summary>
    /// <param name="p_other">collision avec un character</param>
    private void OnTriggerExit(Collider p_other)
    {

        //If the thing we are colliding is a playable character and only him
        if (p_other.gameObject.TryGetComponent(out PlayerController charaScript))
        {
            //enlèvement du personnage qui est sorti
            m_charactersInDangerScript.Remove(charaScript);

            //si personne n'est dans la zone, alors l'ennemi fait sa patrouille normalement
            if (m_charactersInDangerScript.Count < 1)
            {
                m_hasSeenPlayer = false;
                m_nma.speed = m_normalSpeed;
                m_nma.acceleration = m_normalAcceleration;
                m_nma.angularSpeed = m_normalRotationSpeed;
                m_enterZone = false;

                m_attackVibe = false;
                m_warningVibe = false;
                m_intimidationVibe = false;

                //Arrêt de vibration
                Rumbler.Instance.StopRumble();
            }
            
        }
    }
    

    private void Death() {
        m_nma.isStopped = false;
        
        //if he was off his initial path we simply put him back on
        if (m_isGoingTowardsPlayer && !m_isStatic) {
            m_isGoingTowardsPlayer = false;
            m_destinations.Remove(m_destinations[m_currentDestination]);
            m_nma.SetDestination(m_destinations[m_currentDestination]);
        }

        if (m_isStatic) {
            m_nma.SetDestination(m_staticPos);
        }
        
        m_isGoingTowardsPlayer = false;
        transform.position = m_spawnPoint;
    }
    
}