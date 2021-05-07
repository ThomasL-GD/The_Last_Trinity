using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Script du mouvement du player controller
/// Possible amelioration : Empecher l'auto-ajustement de la rotation du joueur lié au Quaternion
/// </summary>
public class PlayerController : MonoBehaviour
{
    [Tooltip("Vitesse du joueur")] public float m_speed = 5f;
    [Tooltip("Vitesse de Rotation du Quaternion")] public float m_rotationSpeed = 700f;
    
    void Update()
    {
        float horizontalInput = Input.GetAxis("Horizontal");
        float verticalInput = Input.GetAxis("Vertical");
        
        Vector3 movementDirection = new Vector3(horizontalInput,  0, verticalInput);
        movementDirection.Normalize();
                
        transform.Translate(movementDirection * m_speed * Time.deltaTime, Space.World);
        
        //Utilisation du Quaternion pour permettre au player de toujours se déplacer dans l'angle où il regarde
        if (movementDirection != Vector3.zero)
        {
            Quaternion toRotation = Quaternion.LookRotation(movementDirection, Vector3.up);
                    
            transform.rotation = Quaternion.RotateTowards(transform.rotation, toRotation, m_rotationSpeed * Time.deltaTime);
        }
    }
}