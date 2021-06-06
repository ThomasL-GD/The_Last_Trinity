using UnityEngine;

[CreateAssetMenu(fileName = "SOLightParameters", menuName = "Lights/LightParameters", order = 1)]
public class SOLight : ScriptableObject
{
    [Header("Open")]
    [SerializeField] [Tooltip("The color of the light when the subPuzzle is open")] public Color colorOpen = Color.yellow;
    [SerializeField] [Tooltip("The material of the light when the subPuzzle is open")] public Material materialOpen = null;
    
    [Header("Finished")]
    [SerializeField] [Tooltip("The color of the light when the subPuzzle is Finished")] public Color colorFinished = Color.green;
    [SerializeField] [Tooltip("The material of the light when the subPuzzle is Finished")] public Material materialFinished = null;
}
