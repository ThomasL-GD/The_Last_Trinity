using UnityEngine;

namespace Scenes.Tests_Code.Prototype.Scripts
{
    public class OpenDoorSub : MonoBehaviour
    {
        [SerializeField] public GameObject m_doorSub;
        private float m_speed = 2.0f;
        private Interact_Detection m_interactDetection;

        void Start()
        {
            m_interactDetection = gameObject.GetComponent<Interact_Detection>();
        }

        void Update()
        {
            if (m_interactDetection.m_openDoor)
            {
                Debug.Log(m_interactDetection.m_openDoor);
                Vector3 movementDirection = new Vector3(0, m_doorSub.transform.position.y - 20, 0);
                movementDirection.Normalize();
                m_doorSub.transform.Translate(movementDirection * (m_speed * Time.deltaTime), Space.World);
            }
        }
    }
}
