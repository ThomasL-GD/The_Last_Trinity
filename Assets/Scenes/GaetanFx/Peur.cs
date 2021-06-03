using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Peur : MonoBehaviour
{

    private Animator m_animator = null;
    private static readonly int peur = Animator.StringToHash("Peur");
    
    // Start is called before the first frame update
    void Start()
    {
        m_animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            m_animator.SetTrigger(peur);
        }
    }
}
