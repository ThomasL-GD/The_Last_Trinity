using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(SphereCollider))]
public class Vision : MonoBehaviour
{
    [Header("Characters")]
    [SerializeField] [Tooltip("tableau qui contient les 3 personnages controlables")] private GameObject[] m_characters ;
    
    private SphereCollider m_sphereCol = null;
    [Header("Difficulty")]
    [SerializeField] [Tooltip("The radius of the detection area")] private float m_radius = 5.0f;
    [SerializeField] [Tooltip("The possible angle of detection")] private float m_angleUncertainty = 9.0f;

    
    /// <summary>
    /// This delegate will be called each time someone or something detects the player
    /// </summary>
    /// <param name="p_vector3">The position of the player when he was detected</param>
    public delegate void GoTo(Vector3 p_vector3);
    public static event GoTo AlarmDelegator;

    // Start is called before the first frame update
    void Start() {

        if (m_characters == null)
        {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO PUT THE CHARACTERS IN THE VISION SCRIPT !");
        }
        //We adapt the collider to the Serialized value we have
        m_sphereCol = gameObject.GetComponent<SphereCollider>();
        m_sphereCol.radius = m_radius;
        m_sphereCol.isTrigger = true;
        
        
    }
    
    /// <summary>
    /// Called each frame as long as the collider is colliding a collider that is isTrigger
    /// </summary>
    /// <param name="p_other">The collider that we are colliding with</param>
    private void OnTriggerStay(Collider p_other) {
        //If the thing we are colliding is a playable character
        if (p_other.gameObject.TryGetComponent(out PlayableCharacter charaScript)){                                                          //(out PlayableCharacterBehavior charaScript)) {
            //We calculate the angle between the target and the vision
            Vector3 targetDir =  (charaScript.gameObject.transform.position - transform.position).normalized;                         //(charaScript.gameObject.transform.position - transform.position).normalized;
            float angle = Mathf.Abs( Vector3.Angle(transform.forward, targetDir));
            
            if (angle <= m_angleUncertainty) {
                //We call the delegator if it isn't empty
                AlarmDelegator?.Invoke(charaScript.gameObject.transform.position);                                                    //AlarmDelegator?.Invoke(charaScript.gameObject.transform.position);
                //If the gameObject is a guard we ask him to follow the player
                if (gameObject.TryGetComponent(out GuardBehavior p_script)) {
                    p_script.CheckOutSomewhere(charaScript.gameObject.transform.position);                                             //p_script.CheckOutSomewhere(charaScript.gameObject.transform.position);
                }
            }
        }
    }
    
}
