using System;
using UnityEngine;

namespace Scenes.Tests_Code.Prototype.Scripts
{
    public class OpenDoor : MonoBehaviour
    {
        [SerializeField] private GameObject m_door;
        private float m_speed = 2.0f;
        private bool m_liftDoor = false;

        private void OnTriggerEnter(Collider p_other)
        {
            m_liftDoor = true;
        }

        void Update()
        {
            Vector3 movementDirection = new Vector3(0, m_door.transform.position.y - 20, 0);
            movementDirection.Normalize();
            if(m_liftDoor) m_door.transform.Translate(movementDirection * (m_speed * Time.deltaTime), Space.World);
        }
    }
}
