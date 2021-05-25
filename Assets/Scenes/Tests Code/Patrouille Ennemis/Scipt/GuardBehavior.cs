using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.InputSystem;

[RequireComponent(typeof(SphereCollider))]
public class GuardBehavior : MonoBehaviour {

    //Collider présent sur notre ennemi
    private SphereCollider m_sphereCol = null;

    //variables d'IA
    public NavMeshAgent m_nma = null;
    private int m_currentDestination = 0;

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

    [Header("Waypoints Manager")]
    [SerializeField] [Tooltip("The list of points the guard will travel to, in order from up to down and cycling")] private List<Transform> m_destinationsTransforms = new List<Transform>();
    private List<Vector3> m_destinations = new List<Vector3>();

    [Header("Death")]
    [SerializeField] [Tooltip("distance d'élimination")] [Range(0f,10f)] private float m_deathPos = 1.0f;
    [SerializeField] [Tooltip("temps d'animation de mort")] [Range(0f,10f)] private float m_deathTime = 3.0f;
    
    [Header("Monster Ability")]
    [SerializeField] [Tooltip("temps de capacité de monstre")] [Range(0f,60f)] private float m_intimidationTime = 1.0f;
    [SerializeField] [Tooltip("temps de stun qu'est l'ennemi")] [Range(0f,180f)] private float m_stunTime = 1.0f;
    
    // [Header("Rumble")]
    // [SerializeField] [Tooltip("valeur de la vibration faible lorsque le character entre dans la zone de l'ennemi")] [Range(0f,1f)] private float m_lowWarningEnemy =0f;
    // [SerializeField] [Tooltip("valeur de la vibration forte lorsque le character entre dans la zone de l'ennemi")] [Range(0f,1f)] private float m_highWarningEnemy =0f;
    // [SerializeField] [Tooltip("valeur de la vibration faible lorsque le character est visible par l'ennemi")] [Range(0f,1f)] private float m_lowAttackEnemy =0f;
    // [SerializeField] [Tooltip("valeur de la vibration forte lorsque le character est visible par l'ennemi")] [Range(0f,1f)] private float m_highAttackEnemy =0f;
    // [SerializeField] [Tooltip("valeur de la vibration faible lorsque le character monstre utilise sa compétence")] [Range(0f,1f)] private float m_lowMonsterIntimidation =0f;
    // [SerializeField] [Tooltip("valeur de la vibration forte lorsque le character monstre utilise sa compétence")] [Range(0f,1f)] private float m_highMonsterIntimidation =0f;
    //private PlayerInput m_playerInput;
    //Gamepad m_gamepad = Gamepad.current;
    // bool m_warningVibe = false; //présence d'un character dans la zone de l'ennemi
    // bool m_intimidationVibe = false;   //utilisation de la compétence du monstre dans la zone de l'ennemi
    // bool m_attackVibe = false;   //attack de l'ennemi sur un character
    
    
    private bool m_enterZone = false;
    private bool m_hasSeenPlayer = false;
    private bool m_isGoingTowardsPlayer = false;
    public static bool m_isKillingSomeone = false;  //tous les script de l'ennemi possèdent la même valeur de la variable au même moment
    [SerializeField] [Tooltip("For Debug Only")] private List<PlayerController> m_charactersInDangerScript = new List<PlayerController>(); //Liste des scripts sur les character qui entrent et sortent de la zone de l'ennemi


    // Start is called before the first frame update
    void Start() {
        
        if(m_destinationsTransforms.Count < 1) Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO PUT DESTINATIONS IN THE ENNEMY !");

        //We adapt the collider to the Serialized value we have
        m_sphereCol = gameObject.GetComponent<SphereCollider>();
        m_sphereCol.radius = m_sphereRadius;
        m_sphereCol.isTrigger = true;
        
        //We transform the list of Transforms (easier to serialize) into a list of Vector3 (easier to manipulate)
        for (int i = 0; i < m_destinationsTransforms.Count; i++) { m_destinations.Add(m_destinationsTransforms[i].position); }
        m_nma = gameObject.GetComponent<NavMeshAgent>();
        
        //The first position where the guard will aim at
        m_nma.SetDestination(m_destinations[m_currentDestination]);

        //m_playerInput = GetComponent<PlayerInput>();
        //m_gamepad = GetGamepad();
    }
    

    // Update is called once per frame
    void Update()
    {
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

        /*
        if (m_warningVibe && !m_intimidationVibe && !m_attackVibe) m_gamepad.SetMotorSpeeds(m_lowWarningEnemy, m_highWarningEnemy);
        else if(m_intimidationVibe && !m_warningVibe && !m_attackVibe) m_gamepad.SetMotorSpeeds(m_lowMonsterIntimidation, m_highMonsterIntimidation);
        else if(m_attackVibe && !m_warningVibe && !m_intimidationVibe) m_gamepad.SetMotorSpeeds(m_lowAttackEnemy, m_highAttackEnemy);
        else if (!m_warningVibe && !m_attackVibe && !m_intimidationVibe)
        {
            m_gamepad.SetMotorSpeeds(0.0f, 0.0f);
        }
        */

        if (m_enterZone && !m_isKillingSomeone)
        {
            // m_warningVibe = true;
            // m_intimidationVibe = false;
            // m_attackVibe = false;

            //calcul de la position du premier chara entré dans la zone
            Vector3 targetDir = (m_charactersInDangerScript[0].gameObject.transform.position - transform.position).normalized;
            //angle de détection lorsque l'ennemi est à peu près en face du joueur
            float angleForward = Vector3.Angle(transform.forward, targetDir);
            

            //création de la variable du  raycast
            RaycastHit hit;
            //création physique du raycast
            bool raycastHasHit = Physics.Raycast(transform.position, targetDir, out hit, m_sphereRadius * 5);
            
            //Debug du raycast dans la scène
            if (raycastHasHit)
            {
                Debug.DrawRay(transform.position, targetDir * hit.distance, Color.magenta, 10f);
                
                if (m_charactersInDangerScript[0].gameObject.transform.position != hit.transform.position) //le chara se trouve derrière un obstacle et n'est pas visible par l'ennemi
                {
                    //Debug.Log("Oulala on ne voit pas le character derrière");
                }
                else //le chara est visible par l'ennemi
                {
                    //INTIMIDATION DU MONSTRE
                    if (Input.GetKeyDown(m_charactersInDangerScript[0].m_selector.inputMonster))
                    {
                        // m_warningVibe = false;
                        // m_intimidationVibe = true;
                        // m_attackVibe = false;
                        StartCoroutine("Intimidate");
                    }
                    
                    //Si le joueur est dans l'angle mort de l'ennemi
                    if (Mathf.Abs(angleForward) > m_angleUncertainty)
                    {
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
                    else if (angleForward <= m_angleUncertainty)
                    {
                        // m_warningVibe = false;
                        // m_intimidationVibe = false;
                        // m_attackVibe = true;
                        
                        m_hasSeenPlayer = true;
                        CheckOutSomewhere(m_charactersInDangerScript[0].gameObject.transform.position);
                        m_nma.speed = m_attackSpeed;
                        m_nma.acceleration = m_attackAcceleration;
                        m_nma.angularSpeed = m_attackRotationSpeed;

                        //mort du joueur dès qu'il est assez proche
                        if (Vector3.Distance(m_charactersInDangerScript[0].transform.position, transform.position) < m_deathPos)
                        {
                            Debug.Log("J'AI TROUVE UNE VICTIME");
                            StartCoroutine(DeathCoroutine());
                        }
                    }
                }
            }
            else {}//Debug.LogWarning("The raycast hit nothing nowhere");
        }
            
    }

    IEnumerator Intimidate()
    {
        m_nma.isStopped = true;
        PlayerController scriptCharaWhoIsDying = m_charactersInDangerScript[0];
        scriptCharaWhoIsDying.m_isForbiddenToMove = true;
        
        yield return new WaitForSeconds(m_intimidationTime); //temps d'animation d'intimidation
        //m_gamepad.SetMotorSpeeds(0.0f, 0.0f);
        scriptCharaWhoIsDying.m_isForbiddenToMove = false;
        StartCoroutine(Stun());
    }

    IEnumerator Stun()
    {
        yield return new WaitForSeconds(m_stunTime); //durée de stun
        m_nma.isStopped = false;
    }

    IEnumerator DeathCoroutine()
    {
        m_isKillingSomeone = true;
        PlayerController scriptCharaWhoIsDying = m_charactersInDangerScript[0];
        m_nma.isStopped = true;
        scriptCharaWhoIsDying.m_isForbiddenToMove = true;
        yield return new WaitForSeconds(m_deathTime); //temps d'animation de mort du monstre

        scriptCharaWhoIsDying.Death();  //mort   // We will reset m_isForbiddenToMove in there
        m_nma.isStopped = false;
        m_isKillingSomeone = false;
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

                // m_attackVibe = false;
                // m_warningVibe = false;
                // m_intimidationVibe = false;
            }
            
        }
    }

    /*
    // Private helpers
    private Gamepad GetGamepad()
    {
        return Gamepad.all.FirstOrDefault(g => m_playerInput.devices.Any(d => d.deviceId == g.deviceId));

        #region Linq Query Equivalent Logic
        //Gamepad gamepad = null;
        //foreach (var g in Gamepad.all)
        //{
        //    foreach (var d in _playerInput.devices)
        //    {
        //        if(d.deviceId == g.deviceId)
        //        {
        //            gamepad = g;
        //            break;
        //        }
        //    }
        //    if(gamepad != null)
        //    {
        //        break;
        //    }
        //}
        //return gamepad;
        #endregion
    }
    */
}