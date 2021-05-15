using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

[RequireComponent(typeof(SphereCollider))]
public class GuardBehavior : MonoBehaviour {

    private SphereCollider m_sphereCol = null;
    private NavMeshAgent m_nma = null;
    private int m_currentDestination = 0;
    private bool m_isGoingTowardsPlayer = false;
    
    [Header("Difficulty")]
    [SerializeField] [Tooltip("The radius of the detection area")] private float m_radius = 5.0f;
    [SerializeField] [Tooltip("The possible angle of detection")] private float m_angleUncertainty = 9.0f;
    [SerializeField] [Tooltip("The maximum authorized difference between the position to reach and the current position (unit : Unity meters)")] private float m_uncertainty = 0.1f;
    
    [Header("Waypoints Manager")]
    [SerializeField] [Tooltip("The list of points the guard will travel to, in order from up to down and cycling")] private List<Transform> m_destinationsTransforms = new List<Transform>();
    private List<Vector3> m_destinations = new List<Vector3>();


    // Start is called before the first frame update
    void Start() {
        
        //We adapt the collider to the Serialized value we have
        m_sphereCol = gameObject.GetComponent<SphereCollider>();
        m_sphereCol.radius = m_radius;
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
    }

    
    /// <summary>
    /// This function is called by the Delegator each time someone or something detect the player
    /// it is only called if m_isaPCGuard is true
    /// </summary>
    /// <param name="p_playerPos">The last detected position of the player</param>
    public void CheckOutSomewhere(Vector3 p_playerPos) {
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
    private void OnTriggerStay(Collider p_other) {
        
        
        //If the thing we are colliding is a playable character
        if (p_other.gameObject.TryGetComponent(out PlayerController charaScript)){
            
            Debug.Log("Character detection");
            
            //We calculate the angle between the target and the vision
            Vector3 targetDir =  (charaScript.gameObject.transform.position - transform.position).normalized;
            float angle = Mathf.Abs( Vector3.Angle(transform.forward, targetDir));
            
            if (angle <= m_angleUncertainty) {
                //If the gameObject is a guard we ask him to follow the player
                if (gameObject.TryGetComponent(out GuardBehavior p_script)){
                    p_script.CheckOutSomewhere(charaScript.gameObject.transform.position);
                }
            }
        }
    }


}