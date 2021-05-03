using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Door : MonoBehaviour
{
    public Key_SO m_keyToOpen;
    public bool m_isOpened = false;
    [SerializeField] private float m_speed = 10.0f;

    private Quaternion m_rotateTo;

    private void Update()
    {
        if (m_isOpened)
        {
            transform.rotation = Quaternion.Lerp(transform.rotation, m_rotateTo, Time.deltaTime * m_speed);
        }
    }
}
