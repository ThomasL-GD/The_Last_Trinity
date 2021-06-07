using UnityEngine;

[RequireComponent(typeof(BoxCollider))]
public class TrashDestroyer : MonoBehaviour {
    private void OnCollisionEnter(Collision p_other) {
        
        Destroy(p_other.gameObject);
    }
}
