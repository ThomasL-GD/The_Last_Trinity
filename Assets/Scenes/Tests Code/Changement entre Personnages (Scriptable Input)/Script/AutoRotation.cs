using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoRotation : MonoBehaviour {

    [SerializeField] [Tooltip("The speed at which the object will rotate")] private float m_rotationStrength = 10.0f;
    [SerializeField] [Range(0.01f, 2f)] [Tooltip("The time taken for the object to go to its target (unit : seconds)")] public float m_duration = 2.0f;
    private float m_durationLeft = 2.0f;
    [SerializeField] [Range(0.0f, 1.2f)] [Tooltip("The distance between this object and its target at which this object will auto-destroy (unit : meters)")] private float m_uncertainty = 0.2f;
    [HideInInspector] public Transform m_target = null;
    [HideInInspector] public Vector3 m_offsetTarget = Vector3.zero;
    private bool m_targetNull = true;

    private void OnEnable() {
        m_targetNull = true;
    }

    // Update is called once per frame
    void Update()
    {
        if (m_targetNull && m_target != null) {
            m_targetNull = false;
            m_durationLeft = m_duration;
        }

        if (!m_targetNull) {
            transform.Rotate(Vector3.up, m_rotationStrength);

            transform.position = transform.position + (m_target.position + m_offsetTarget - transform.position).normalized * Time.deltaTime * (Mathf.Abs((m_target.position + m_offsetTarget - transform.position).magnitude) / m_durationLeft);

            m_durationLeft -= Time.deltaTime;
            
            if (Mathf.Abs((m_target.position + m_offsetTarget - transform.position).magnitude) <= m_uncertainty) {
                Debug.Log("Goodbye, cruel world...");
                
                Destroy(gameObject);
            }
        }
    }
}
