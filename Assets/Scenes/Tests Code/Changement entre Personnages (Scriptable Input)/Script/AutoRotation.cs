using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class AutoRotation : MonoBehaviour {

    [SerializeField] [Tooltip("The speed at which the object will rotate")] private float m_rotationStrength = 10.0f;
    [SerializeField] [Range(0.01f, 2f)] [Tooltip("The time taken for the object to go to its target (unit : seconds)")] public float m_duration = 2.0f;
    private float m_durationLeft = 2.0f;
    [SerializeField] [Range(0.0f, 1.2f)] [Tooltip("The distance between this object and its target at which this object will auto-destroy (unit : meters)")] private float m_uncertainty = 0.2f;
    [HideInInspector] public Transform m_target = null;
    [HideInInspector] public Vector3 m_offsetTarget = Vector3.zero;
    private bool m_targetNull = true;
    private VisualEffect m_visualEffect = null;

    private void Start() {
        //We just check out if the game designer did his job
        if (TryGetComponent(out VisualEffect visualEffect)) {
            m_visualEffect = visualEffect;
        }
        else {
            visualEffect = GetComponentInChildren<VisualEffect>();
            if(visualEffect != null) {
                m_visualEffect = visualEffect;
                Debug.LogWarning("Watch out ! The vfx is in a child of the soul's gameobject instead of being on the soul itself");
            }
            else {
                Debug.LogError("JEEZ ! THERE'S NO VISUAL EFFECT COMPONENT ON THE SOUL");
            }
        }
    }

    private void OnEnable() {
        m_targetNull = true;
    }

    // Update is called once per frame
    void Update()
    {
        if (m_targetNull && m_target != null) {
            m_targetNull = false;
            m_durationLeft = m_duration;
            m_visualEffect.Play();
        }

        if (!m_targetNull) {
            Transform transform1;
            (transform1 = transform).Rotate(Vector3.up, m_rotationStrength);

            var position = transform1.position;
            var positionTarget = m_target.position;
            transform.position = position + (positionTarget + m_offsetTarget - position).normalized * Time.deltaTime * (Mathf.Abs((positionTarget + m_offsetTarget - position).magnitude) / m_durationLeft);

            m_durationLeft -= Time.deltaTime;
            
            if (Mathf.Abs((positionTarget + m_offsetTarget - transform.position).magnitude) <= m_uncertainty) {
                m_target = null;
                m_targetNull = true;
                m_visualEffect.Stop();
            }
        }
    }
}
