using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class GuardBehavior : MonoBehaviour {

    [SerializeField] [Tooltip("The list of points the guard will travel to, in order from up to down and cycling")] private List<Transform> m_destinationsTransforms = new List<Transform>();
    private List<Vector3> m_destinations = new List<Vector3>();
    [SerializeField] [Tooltip("The maximum authorized difference between the position to reach and the current position (unit : Unity meters)")] private float m_uncertainty = 0.1f;
    private int m_currentDestination = 0;
    private NavMeshAgent m_nma = null;
    private bool m_isGoingTowardsPlayer = false;
    [SerializeField] [Tooltip("If true, this guard will go to every report from another guard or camera")] private bool m_isaPCGuard = false;
    
    
    // Start is called before the first frame update
    void Start() {
        //We transform the list of Transforms (easier to serialize) into a list of Vector3 (easier to manipulate)
        for (int i = 0; i < m_destinationsTransforms.Count; i++) {
            m_destinations.Add(m_destinationsTransforms[i].position);
        }
        m_nma = gameObject.GetComponent<NavMeshAgent>();
        //The first position where the guard will aim at
        m_nma.SetDestination(m_destinations[m_currentDestination]);
        if (m_isaPCGuard) {
            Vision.AlarmDelegator += CheckOutSomewhere;
        } 
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



}