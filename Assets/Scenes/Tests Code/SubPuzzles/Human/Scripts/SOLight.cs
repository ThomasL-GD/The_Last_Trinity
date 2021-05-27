using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "SOLightParameters", menuName = "Lights/LightParameters", order = 1)]
public class SOLight : MonoBehaviour
{
    [Header("Open")]
    [SerializeField] [Tooltip("The color of the light when the subPuzzle is open")] public Color m_colorOpen = Color.yellow;
    [SerializeField] [Tooltip("The material of the light when the subPuzzle is open")] public Material m_materialOpen = null;
    
    [Header("Finished")]
    [SerializeField] [Tooltip("The color of the light when the subPuzzle is Finished")] public Color m_colorFinished = Color.green;
    [SerializeField] [Tooltip("The material of the light when the subPuzzle is Finished")] public Material m_materialFinished = null;
    
    [Header("Failed")]
    [SerializeField] [Tooltip("The color of the light when the subPuzzle is Failed")] public Color m_colorFailed = Color.red;
    [SerializeField] [Tooltip("The material of the light when the subPuzzle is Failed")] public Material m_materialFailed = null;
}
