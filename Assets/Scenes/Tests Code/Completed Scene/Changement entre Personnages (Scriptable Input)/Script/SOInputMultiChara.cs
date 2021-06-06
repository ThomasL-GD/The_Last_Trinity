using UnityEngine;

[CreateAssetMenu(fileName = "InputMultiChara", menuName = "Inputs/InputMultiChara", order = 1)]
public class SOInputMultiChara : ScriptableObject {
    
    
    //Déplacement hors subpuzzle
    [SerializeField] public KeyCode inputHuman = KeyCode.Joystick1Button0;
    [SerializeField] public KeyCode inputMonster = KeyCode.Joystick1Button3;
    [SerializeField] public KeyCode inputRobot = KeyCode.Joystick1Button1;

}