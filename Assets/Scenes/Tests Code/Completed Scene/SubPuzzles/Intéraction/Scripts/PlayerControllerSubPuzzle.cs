using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Script du mouvement du player controller dans le jeu et les subpuzzle
/// Possible amelioration : Empecher l'auto-ajustement de la rotation du joueur lié au Quaternion
/// </summary>
public class PlayerControllerSubPuzzle : MonoBehaviour
{
    [Tooltip("Vitesse du joueur")] public float m_speed = 5f;
    [Tooltip("Vitesse de Rotation du Quaternion")] public float m_rotationSpeed = 700f;

    
    [SerializeField] [Tooltip("variable booléènne qui indique le passage entre puzzle et sub puzzle")]
    private bool m_isInSubPuzzle = false;

    [SerializeField] [Tooltip("vitesse de déplacement dans le sub puzzle")]
    private float m_subPuzzleSpeed = 10f;
    
    [SerializeField] [Tooltip("objet qui englobe tout le sub puzzle")]
    private GameObject m_globalSubPuzzle;
    
    [SerializeField] [Tooltip("objet qui contient une animation du sub puzzle")]
    private GameObject m_subPuzzleAnimation;
    
    [Tooltip("Bouton qui apparait afin de déclencher le puzzle")]
    public GameObject m_activationButton;
    
    [SerializeField] [Tooltip("Objet que le joueur bouge dans le sub puzzle")]
    private GameObject m_selectorSubPuzzle;

    [SerializeField] [Tooltip("Objet sur lequel le joueur doit faire le sub puzzle")]
    private GameObject m_panneau;

    [Tooltip("position de la camera du jeu")] public Transform m_camera;

    [Tooltip("contrôle d'état du trigger du bouton permettant d'activer le sub puzzle")]
    public bool m_buttonActivate = false;

    void Update()
    {
        float horizontalInput = Input.GetAxis("Horizontal");
        float verticalInput = Input.GetAxis("Vertical");
        
        //Déplacement hors sub puzzle
        Vector3 movementDirection = new Vector3(horizontalInput,  0, verticalInput);
        movementDirection.Normalize();
        
        //déplacement dans le sub puzzle
        Vector2 subPuzzleDirection = new Vector2(horizontalInput, verticalInput);
        
        //Utilisation du Quaternion pour permettre au player de toujours se déplacer dans l'angle où il regarde
        if (movementDirection != Vector3.zero && !m_isInSubPuzzle)
        {
            Quaternion toRotation = Quaternion.LookRotation(movementDirection, Vector3.up);
                    
            transform.rotation = Quaternion.RotateTowards(transform.rotation, toRotation, m_rotationSpeed * Time.deltaTime);
        }
        
        //Déplacement en translation du joueur lorsqu'il n'est pas dans un subpuzzle
        if (!m_isInSubPuzzle)
        {
            transform.Translate(movementDirection * (m_speed * Time.deltaTime), Space.World);
        }
        else if (m_isInSubPuzzle)
        {
            m_selectorSubPuzzle.transform.Translate(subPuzzleDirection * (m_subPuzzleSpeed * Time.deltaTime), Space.Self);
        }

        //à l'activation de l'input et si le bouton d'activation est visible, le joueur rentre dans le sub puzzle
        if (Input.GetKey(KeyCode.A) && m_buttonActivate)
        {
            OpenSubPuzzle();
        }
        
        //Le bouton d'activation regarde toujours en direction de la caméra de jeu
        m_activationButton.transform.LookAt(m_camera);
    }

    /// <summary>
    /// fonction de détection de collision entre le joueur et différents objets
    /// </summary>
    /// <param name="other"></param>
    private void OnTriggerEnter(Collider other)
    {
        //détection d'un objet de type sub puzzle
        if (other.gameObject.CompareTag("SubPuzzle"))
        {
            m_activationButton.SetActive(true);
            m_buttonActivate = true;
        }
    }

    /// <summary>
    /// Bouton d'activation de sub puzzle se désactive si le joueur est trop loin
    /// </summary>
    /// <param name="other"></param>
    private void OnTriggerExit(Collider other)
    {
        m_activationButton.SetActive(false);
        m_buttonActivate = false;
    }

    /// <summary>
    /// Sortie du sub puzzle via le bouton de sortie
    /// </summary>
    public void ExitSubPuzzle()
    {
        m_isInSubPuzzle = false;
        m_globalSubPuzzle.SetActive(false);
    }
    
    /// <summary>
    /// ouverture du sub puzzle et animation de celui-ci
    /// </summary>
    public void OpenSubPuzzle()
    {
        //le joueur rentre dans le sub puzzle
        m_isInSubPuzzle = true;
        
        //Activation du sub puzzle que si on voit le bouton d'activation
        if(m_buttonActivate) m_globalSubPuzzle.SetActive(true);

        if (m_subPuzzleAnimation)
        {
            //Récupération de l'animation sur l'objet m_subPuzzleAnimation
            Animator animator = m_subPuzzleAnimation.GetComponent<Animator>();
            if (animator)
            {
                //attribution d'un booléen à un paramètre de l'animation
                bool isOpen = animator.GetBool("open");
                
                //joue l'animation
                animator.SetBool("open", !isOpen);
            }
        }
    }

}
