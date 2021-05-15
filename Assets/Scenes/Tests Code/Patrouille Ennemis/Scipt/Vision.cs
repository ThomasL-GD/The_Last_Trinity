using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(SphereCollider))]
public class Vision : MonoBehaviour
{
    
    private SphereCollider m_sphereCol = null;
    [Header("Difficulty")]
    [SerializeField] [Tooltip("The radius of the detection area")] private float m_radius = 5.0f;
    [SerializeField] [Tooltip("The possible angle of detection")] private float m_angleUncertainty = 9.0f;

    //[Header("Offset")] 
    //[SerializeField] [Tooltip("décalage du cône de vision par rapport à l'ennemi")] private Vector3 m_size = new Vector3();
    //[SerializeField] [Tooltip("décalage du cône de vision par rapport à l'ennemi")] private Vector3 m_offsetTranslation = new Vector3();
    
    //[Header("Gizmo Manager")]
    //[SerializeField] [Tooltip("angle qui part du joueur")] private float m_angle = 30.0f;
    //[SerializeField] [Tooltip("portée de détection")] private float m_rayRange = 10.0f;
    //[SerializeField] [Tooltip("direction de pointage du cone")] private float m_coneDirection = 180;
    
    
    /// <summary>
    /// This delegate will be called each time someone or something detects the player
    /// </summary>
    /// <param name="p_vector3">The position of the player when he was detected</param>
    public delegate void GoTo(Vector3 p_vector3);
    public static event GoTo AlarmDelegator;

    // Start is called before the first frame update
    void Start() {
        
        //We adapt the collider to the Serialized value we have
        m_sphereCol = gameObject.GetComponent<SphereCollider>();
        m_sphereCol.radius = m_radius;
        m_sphereCol.isTrigger = true;

        OnDrawGizmos();
    }
    

    /// <summary>
    /// Fonction qui affiche une zone de détection
    /// </summary>
    void OnDrawGizmos()
    {

        // Draw a semitransparent blue cube at the transforms position
        Gizmos.color = new Color(50, 200, 255, 0.7f);
        //Cube 1
        //Gizmos.DrawCube(transform.position + m_offsetTranslation, m_size);
        //Quaternion upRayRotation = Quaternion.AngleAxis(-halfFOV + m_coneDirection, Vector3.up);
        
        //Angle de la zone de détection
        float angle = 30.0f;
        
        //Distance de raycast
        float rayRange = 10.0f;
        
        //on coupe en deux l'angle pour créer deux directions de ligne opposées
        float halfFOV = angle / 2.0f;
        
        //direction du cone
        float coneDirection = 180;

        //Création des directions de départ pour les rayons
        Quaternion leftRayRotation = Quaternion.AngleAxis(-halfFOV + coneDirection, Vector3.up);
        Quaternion rightRayRotation = Quaternion.AngleAxis(halfFOV + coneDirection, Vector3.up);

        //ajout d'une longueur de ray par rapport à la précédente direction
        Vector3 leftRayDirection = leftRayRotation * -transform.forward * rayRange;
        Vector3 rightRayDirection = rightRayRotation * -transform.forward * rayRange;

        //création du rayon
        Gizmos.DrawRay(transform.position, leftRayDirection);
        Gizmos.DrawRay(transform.position, rightRayDirection);
        
        //fermeture du cone avec la tangente des deux lignes crées précédemment
        Gizmos.DrawLine(transform.position + rightRayDirection, transform.position + leftRayDirection);

    }
    
    
    /// <summary>
    /// Called each frame as long as the collider is colliding a collider that is isTrigger
    /// </summary>
    /// <param name="p_other">The collider that we are colliding with</param>
    private void OnTriggerStay(Collider p_other) {
        
        Debug.Log("Object detection");
        
        //If the thing we are colliding is a playable character
        if (p_other.gameObject.TryGetComponent(out PlayerController charaScript)){
            
            Debug.Log("Character detection");
            
            //We calculate the angle between the target and the vision
            Vector3 targetDir =  (charaScript.gameObject.transform.position - transform.position).normalized;
            float angle = Mathf.Abs( Vector3.Angle(transform.forward, targetDir));
            
            if (angle <= m_angleUncertainty) {
                //We call the delegator if it isn't empty
                AlarmDelegator?.Invoke(charaScript.gameObject.transform.position);
                //If the gameObject is a guard we ask him to follow the player
                if (gameObject.TryGetComponent(out GuardBehavior p_script)) {
                    p_script.CheckOutSomewhere(charaScript.gameObject.transform.position);
                }
            }
        }
    }
    
}
