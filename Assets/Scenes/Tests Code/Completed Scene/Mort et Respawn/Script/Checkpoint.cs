using UnityEngine;

[RequireComponent(typeof(BoxCollider))]
public class Checkpoint : MonoBehaviour
{
    [SerializeField] [Tooltip("The chara this checkpoint is used for")] private Charas m_chara = Charas.Human;

    private void Start() {
        //Just making sure...
        gameObject.GetComponent<BoxCollider>().isTrigger = true;
    }

    /// <summary>
    /// Is called when a gameObject enters the trigger zone of this game object
    /// Will change the spawn point of a chara according to the current position of this game object
    /// </summary>
    /// <param name="p_other">Default</param>
    private void OnTriggerEnter(Collider p_other)
    {
        if (p_other.gameObject.TryGetComponent(out PlayerController charaScript)) {
            
            if (charaScript.m_chara == m_chara) charaScript.m_spawnPoint = transform.position;
            if (charaScript.m_chara == m_chara) charaScript.m_spawnCamera = charaScript.GetCurrentCamera();
        }
    }
}