using UnityEngine;

[RequireComponent(typeof(BoxCollider))]
public class RigidBodyAdder : MonoBehaviour {

    [SerializeField] [Tooltip("The objects that will suddenly fall")] private GameObject[] m_objects = new GameObject[] { };
    private Rigidbody[] m_RBs = new Rigidbody[] { };
    private bool m_isDone = false;
    
    // Start is called before the first frame update
    void Start() {

        m_RBs = new Rigidbody[m_objects.Length];
        for(int i = 0; i< m_objects.Length; i++) {
            m_RBs[i] = m_objects[i].GetComponent<Rigidbody>();
        }
    }

    private void OnTriggerEnter(Collider p_other) {

        if (!m_isDone && p_other.gameObject.TryGetComponent(out PlayerController charaScript)) {
            m_isDone = true;
            foreach (Rigidbody rb in m_RBs) {
                rb.useGravity = true;
            }

            this.enabled = false;
        }
    }
}
