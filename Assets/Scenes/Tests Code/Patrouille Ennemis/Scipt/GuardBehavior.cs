using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Rendering.UI;
using UnityEngine.Serialization;
using UnityEngine.SocialPlatforms;

[RequireComponent(typeof(SphereCollider))]
public class GuardBehavior : MonoBehaviour {

    //Collider présent sur notre ennemi
    private SphereCollider m_sphereCol = null;

    //variables d'IA
    private NavMeshAgent m_nma = null;
    private int m_currentDestination = 0;

    [Header("Metrics")] 
    [SerializeField] [Tooltip("Vitesse de déplacement normale")] [Range(0,50)] private float m_normalSpeed = 5.0f;
    [SerializeField] [Tooltip("Vitesse de déplacement aggressive")] [Range(0,50)] private float m_attackSpeed = 15.0f;
    [SerializeField] [Tooltip("Vitesse d'accélération normale")] [Range(0,50)] private float m_normalAcceleration = 5.0f;
    [SerializeField] [Tooltip("Vitesse d'accélération aggressive")] [Range(0,50)] private float m_attackAcceleration = 15.0f;
    [SerializeField] [Tooltip("Vitesse de rotation normale")] [Range(0,10000)] private float m_normalRotationSpeed = 300.0f;
    [SerializeField] [Tooltip("Vitesse de rotation aggressive")] [Range(0,10000)] private float m_attackRotationSpeed = 900.0f;
    
    [Header("Death")]
    [SerializeField] [Tooltip("distance d'élimination")] [Range(0,100)] private float m_deathPos = 1.0f;
    [SerializeField] [Tooltip("temps d'animation de mort")] [Range(0,10)] private float m_deathTime = 3.0f;
    
    [Header("SphereManager")]
    [SerializeField] [Tooltip("The radius of the detection area")] private float m_sphereRadius = 2.0f;
    [SerializeField] [Tooltip("The possible angle of detection")] private float m_angleUncertainty = 9.0f;
    [SerializeField] [Tooltip("The maximum authorized difference between the position to reach and the current position (unit : Unity meters)")] private float m_uncertainty = 0.1f;

    [Header("Waypoints Manager")]
    [SerializeField] [Tooltip("The list of points the guard will travel to, in order from up to down and cycling")] private List<Transform> m_destinationsTransforms = new List<Transform>();
    private List<Vector3> m_destinations = new List<Vector3>();

    
    private bool m_enterZone = false;
    private bool m_hasSeenPlayer = false;
    private bool m_isGoingTowardsPlayer = false;
    private List<PlayerController> m_charactersInDangerScript = new List<PlayerController>(); //Liste des scripts sur les character qui entrent et sortent de la zone de l'ennemi
    
    
    // Start is called before the first frame update
    void Start()
    {

        //We adapt the collider to the Serialized value we have
        m_sphereCol = gameObject.GetComponent<SphereCollider>();
        m_sphereCol.radius = m_sphereRadius;
        m_sphereCol.isTrigger = true;
        
        //We transform the list of Transforms (easier to serialize) into a list of Vector3 (easier to manipulate)
        for (int i = 0; i < m_destinationsTransforms.Count; i++) {
            m_destinations.Add(m_destinationsTransforms[i].position);
        }
        m_nma = gameObject.GetComponent<NavMeshAgent>();
        
        //The first position where the guard will aim at
        m_nma.SetDestination(m_destinations[m_currentDestination]);
    }
    

    // Update is called once per frame
    void Update() {
        
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


        if (m_enterZone) {
            
            //calcul de la position du premier chara entré dans la zone
            Vector3 targetDir = (m_charactersInDangerScript[0].gameObject.transform.position - transform.position).normalized;
            //angle de détection lorsque l'ennemi est à peu près en face du joueur
            float angleForward = Vector3.Angle(transform.forward, targetDir);

            //Layer
            int layerMask = 1 << 8; //0b1000_0000
            layerMask = ~layerMask; //0b0111_1111

            //création de la variable du  raycast
            RaycastHit hit;
            //création physique du raycast
            bool raycastHasHit = Physics.Raycast(transform.position, targetDir, out hit, m_sphereRadius * 5);
            
            //Debug du raycast dans la scène
            if (raycastHasHit)
            {
                //Debug.DrawRay(transform.position, targetDir * hit.distance, Color.magenta, 10f);
                
                if (m_charactersInDangerScript[0].gameObject.transform.position != hit.transform.position) //le chara se trouve derrière un obstacle et n'est pas visible par l'ennemi
                {
                    Debug.Log("Oulala on ne voit pas le character derrière");
                }
                else //le chara est visible par l'ennemi
                {
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
                        m_hasSeenPlayer = true;
                        CheckOutSomewhere(m_charactersInDangerScript[0].gameObject.transform.position);
                        m_nma.speed = m_attackSpeed;
                        m_nma.acceleration = m_attackAcceleration;
                        m_nma.angularSpeed = m_attackRotationSpeed;
                        
                        //mort du joueur dès qu'il est assez proche
                        if (Vector3.Distance(m_charactersInDangerScript[0].transform.position, transform.position) < m_deathPos) StartCoroutine("DeathCoroutine");
                    }
                }
            }
            else {}//Debug.LogWarning("The raycast hit nothing nowhere");
        }
        
        if(m_charactersInDangerScript.Count>=1) Debug.Log($"{m_charactersInDangerScript[0].m_isForbiddenToMove}");
    }

    
    IEnumerator DeathCoroutine() {

        m_nma.isStopped = true;
        m_charactersInDangerScript[0].m_isForbiddenToMove = true;
        yield return new WaitForSeconds(m_deathTime); //temps d'animation de mort du monstre
        //m_charactersInDangerScript[0].m_isForbiddenToMove = false;
        DeathManager.DeathDelegator?.Invoke();  //mort
        m_nma.isStopped = false;
    }
    
    
    /// <summary>
    /// This function is called by the Delegator each time someone or something detect the player
    /// it is only called if m_isaPCGuard is true
    /// </summary>
    /// <param name="p_playerPos">The last detected position of the player</param>
    private void CheckOutSomewhere(Vector3 p_playerPos) {
        
        //If the guard was already off his path, we cancel his last destination
        if (m_isGoingTowardsPlayer) {
            m_destinations.Remove(m_destinations[m_currentDestination]);
        }
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
            m_hasSeenPlayer = false;
            if(charaScript.m_isForbiddenToMove = true) charaScript.m_isForbiddenToMove = false;
            m_nma.speed = m_normalSpeed;
            m_nma.acceleration = m_normalAcceleration;
            m_nma.angularSpeed = m_normalRotationSpeed;

            //enlèvement du personnage qui est sorti
            m_charactersInDangerScript.Remove(charaScript);
        }
        
        //si personne n'est dans la zone, alors l'ennemi fait sa patrouille normalement
        if (m_charactersInDangerScript.Count < 1)
        {
            m_enterZone = false;
        }
    }

}