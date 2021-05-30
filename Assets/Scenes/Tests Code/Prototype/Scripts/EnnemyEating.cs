using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Animator))]
public class EnnemyEating : MonoBehaviour {

    private Animator m_animator = null;
    private static readonly int devour = Animator.StringToHash("Devour");
    
    // Start is called before the first frame update
    void Start()
    {
        GetComponent<Animator>().SetTrigger(devour);
    }
}
