using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class HumanSubPuzzle : MonoBehaviour {

    [Serializable]
    public class Selector {
        public int x = 0;
        public int y = 0;

        public Selector(int p_x, int p_y) {
            x = p_x;
            y = p_y;
        }
    }
    
    private Selector m_selector = new Selector(0,0); //Contains the coordinates of our selector aka the position of th player
    private GameObject m_player = null; //Contains the coordinates of our selector aka the position of th player
    [HideInInspector] [Tooltip("Script d'intéraction entre le personnage et l'objet comprenant le subpuzzle")] public Interact_Detection m_interactDetection = null;
    
    [Header("Input Manager")]
    [SerializeField] public SOInputMultiChara m_inputs = null;
    [HideInInspector] [Tooltip("position limite de joystick")] private float m_limitPosition = 0.5f;
    [HideInInspector] [Tooltip("variable de déplacement en points par points du sélecteur")] private bool m_hasMoved = false;
    
    [Header("Balancing")]
    [SerializeField] [Tooltip("The height of the maze (unit : cells)")] [Range(2,50)] public int m_mazeHeight = 5;
    [SerializeField] [Tooltip("The width of the maze (unit : cells)")] [Range(2,50)] public int m_mazeWidth = 5;
    [SerializeField] [Tooltip("The number of random removed walls\n(Warning ! This function can remove walls that are already removed by the base algorithm) ")] [Range(0,500)] public int m_wallsToRemove = 5;
    [SerializeField] [Tooltip("If on, Every cell that is closed by all four directions will open itself (warning ! does not prevent a group of cells to be closed from the rest of the maze)")] private bool m_isBreakingClosedCells = true;
    [SerializeField] [Tooltip("The number of random removed walls AFTER the breaking of closed cells\n(Warning ! If isBreakingClosedCells is false, this parameter won't be used !)\n(Warning ! This function can remove walls that are already removed by the base algorithm) ")] [Range(0,500)] public int m_wallsToRemoveAfterBreaking = 5;
    
    /*Contains every cell of the maze and if each cell have a wall above, under, on the right or on the left of itself*/private Directions[,] m_maze = null;
    
    /*"Size of each cell (in anchor values so between 0 and 1"*/ private float m_offset = 0.25f;

    [Header("Prefabs for visual representation")]
    [SerializeField] [Tooltip("The visual representation of the player")] private GameObject m_prefabPlayer = null;
    [SerializeField] [Tooltip("The prefab of the background")] private GameObject m_prefabBG = null;
    
    [Header("Debug")]
    [SerializeField] [Tooltip("If on, the walls will be displayed for debug")] private bool m_debugMode = false;
    [SerializeField] [Tooltip("For debug only")] private GameObject m_prefabUp = null;
    [SerializeField] [Tooltip("For debug only")] private GameObject m_prefabLeft = null;
    [SerializeField] [Tooltip("For debug only")] private GameObject m_prefabRight = null;
    [SerializeField] [Tooltip("For debug only")] private GameObject m_prefabDown = null;
    
    
    /// <summary>
    /// OnEnable is called once each time the Game Object is enabled
    /// In our case, it will initialize the maze
    /// </summary>
    void OnEnable() {
        
        SquarePanelToScreen();
        

        if (m_mazeHeight < 2 || m_mazeWidth < 2) {
            Debug.LogError("Invalid size of the maze ! each dimension must be 2 or more cell long");
        }
        if (m_wallsToRemove + m_wallsToRemoveAfterBreaking >= m_mazeHeight * m_mazeWidth * 4) {
            Debug.LogWarning("Warning ! You want to remove to many random walls from the maze, it's gonna be either way too easy or completely fucked up");
        }
        
        //We calculate the size of each cell
        m_offset = 0f;
        if (m_mazeWidth > m_mazeHeight) {
            m_offset = (1f/m_mazeWidth);
        }
        else {
            m_offset = (1f/m_mazeHeight);
        }
        
        m_maze = new Directions[m_mazeHeight, m_mazeWidth];

        //Initialization of the array, we fill it with full cells
        for (int i = 0; i < m_maze.GetLength(0); i++) {
            for (int j = 0; j < m_maze.GetLength(1); j++) {
                m_maze[i, j] = Directions.All; //It's basically 0b0000_1111
            }
        }

        MazeInitialization();
    }

    /// <summary>
    /// Will remove walls from the full maze in order to have at least one possible solution and then break some random walls
    /// </summary>
    private void MazeInitialization() {

        
        GenerateMazeSolution();
        
        
        //Now it's time to break random walls in order to have new paths emerging
        for (int i = 0; i < m_wallsToRemove; i++) {
            
            //The selector has its x and y reversed becaus eof the EraseRandomWall function
            Selector select = new Selector(Random.Range(0, m_maze.GetLength(1)), Random.Range(0, m_maze.GetLength(0)));
            EraseRandomWall(select);
            
        }
        
        //If m_isBreakingClosedCells is true, we're gonna look into the entire  maze and break closed cells
        if (m_isBreakingClosedCells) {
            for (int i = 0; i < m_maze.GetLength(0); i++) {
                for (int j = 0; j < m_maze.GetLength(1); j++) {
                    //If any cell is full of walls, we break one randomly
                    if (m_maze[i, j] == Directions.All) {
                        EraseRandomWall(new Selector(j, i));
                    }
                }
            }
            
            //Now it's time to break random walls again
            for (int i = 0; i < m_wallsToRemoveAfterBreaking; i++) {
            
                //The selector has its x and y reversed becaus eof the EraseRandomWall function
                Selector select = new Selector(Random.Range(0, m_maze.GetLength(1)), Random.Range(0, m_maze.GetLength(0)));
                EraseRandomWall(select);
            
            }
        }
        
        
        //We just fill the borders with walls to avoid the player to escape
         for (int i = 0; i < m_maze.GetLength(0); i++) {
             for (int j = 0; j < m_maze.GetLength(1); j++) {
                 //Up Border
                 if (i == m_maze.GetLength(0) - 1) m_maze[i, j] |= Directions.Up;
                 
                 //Down Border
                 if (i == 0) m_maze[i, j] |= Directions.Down;
                 
                 //Left Border
                 if (j == 0) m_maze[i, j] |= Directions.Left;
                 
                 //Right Border
                 if (j == m_maze.GetLength(1) - 1) m_maze[i, j] |= Directions.Right;
             }
         }


        //Visual representation
        if (m_debugMode) {
        
            for (int i = 0; i < m_maze.GetLength(0); i++) {
                for (int j = 0; j < m_maze.GetLength(1); j++) {

                    GameObject instance = Instantiate(m_prefabBG, new Vector3(transform.position.x, transform.position.y, transform.position.z + 0.5f), transform.rotation, gameObject.transform);
                    SetRectPosition(instance,j,i);
                    instance.transform.SetSiblingIndex(0);

                    if (m_maze[i, j].HasFlag(Directions.Up)) {
                        instance = Instantiate(m_prefabUp, transform.position, transform.rotation, gameObject.transform);
                        SetRectPosition(instance,j,i);
                    }
                    if (m_maze[i, j].HasFlag(Directions.Down)) {
                        instance = Instantiate(m_prefabDown, transform.position, transform.rotation, gameObject.transform);
                        SetRectPosition(instance,j,i);
                    }
                    if (m_maze[i, j].HasFlag(Directions.Left)) {
                        instance = Instantiate(m_prefabLeft, transform.position, transform.rotation, gameObject.transform);
                        SetRectPosition(instance,j,i);
                    }
                    if (m_maze[i, j].HasFlag(Directions.Right)) {
                        instance = Instantiate(m_prefabRight, transform.position, transform.rotation, gameObject.transform);
                        SetRectPosition(instance,j,i);
                    }
                
                }
            }
        }
        else { // If we're not in debug mode, we just display the background
        
            for (int i = 0; i < m_maze.GetLength(0); i++) {
                for (int j = 0; j < m_maze.GetLength(1); j++) {

                    GameObject instance = Instantiate(m_prefabBG, new Vector3(transform.position.x, transform.position.y, transform.position.z + 0.5f), transform.rotation, gameObject.transform);
                    SetRectPosition(instance, j, i);
                    
                }
            }
        }
        
        //Player sprite instantiate
        if (m_prefabPlayer != null) {
            m_player = Instantiate(m_prefabPlayer, new Vector3(0, 0, 0), transform.rotation, gameObject.transform);
            SetRectPosition(m_player, 0, m_mazeHeight - 1);
            m_player.transform.SetSiblingIndex(m_mazeHeight*m_mazeWidth+1);
            m_selector.x = 0;
            m_selector.y = m_mazeHeight - 1;
        }
        else {
            Debug.LogError("Missing prefab for the player in the Human SubPuzzle script");
        }

    }

    /// <summary>
    /// Will erase a random wall and make sure its opposite wall gets destroyed as well
    /// </summary>
    /// <param name="p_select">
    /// The coordinates in m_maze of the cell to which erase a wall
    /// WARNING ! WE USE "m_maze[p_select.y, p_select.x]" TO NAVIGATE IN THE MAZE
    /// </param>
    private void EraseRandomWall(Selector p_select) {
        
        //We select a random direction and a random tile to break a wall
        Directions removedDirection = RandomDirectionBetween(Directions.All);
            
        m_maze[p_select.y, p_select.x] &= ~removedDirection;
            
        //Once we removed a wall, we make sure the adjacent cell (if it exists) will have its opposite wall removed as well
        if (removedDirection == Directions.Up && p_select.y != m_mazeHeight - 1) {
            m_maze[p_select.y+1, p_select.x] &= ~Directions.Down;
        }
        else if (removedDirection == Directions.Down && p_select.y != 0) {
            m_maze[p_select.y-1, p_select.x] &= ~Directions.Up;
        }
        else if (removedDirection == Directions.Left && p_select.x != 0) {
            m_maze[p_select.y, p_select.x-1] &= ~Directions.Right;
        }
        else if (removedDirection == Directions.Right && p_select.x != m_mazeWidth - 1) {
            m_maze[p_select.y, p_select.x+1] &= ~Directions.Left;
        }
    }

    /// <summary>
    /// Will calculate a possible way to solve the maze and destroy every wall in its way in order to let the player have at least one possible solution to solve the maze
    /// </summary>
    private void GenerateMazeSolution() {
        
        // We create a path from the beginning to the end that will create holes in the maze in order to make sure there's at least one possible solution for the player;
        //We create a path head that will move in the maze and initialize it in 0,0
        Selector pathHead = new Selector(0, m_mazeHeight - 1);
        //We create a path variable that will stock every position the pathhead have taken
        List<Vector2> path = new List<Vector2>();
        
        while (!(pathHead.x == m_mazeWidth - 1 && pathHead.y == 0)) {

            Directions authorizedDirections = Directions.All;
            path.Add(new Vector2(pathHead.x, pathHead.y));

            //We forbid some movement when the path head is on a border
            if (pathHead.x == 0) {
                //The Left border forbids left & up
                authorizedDirections &= ~(Directions.Left | Directions.Up);
            }
            if (pathHead.y == m_mazeHeight - 1) {
                //The Up border forbids left & up
                authorizedDirections &= ~(Directions.Left | Directions.Up);
            }
            if (pathHead.x == m_mazeWidth - 1) {
                //The Right border forbids right & up
                authorizedDirections &= ~(Directions.Right | Directions.Up);
            }
            if (pathHead.y == 0) {
                //The Down border forbids down & left
                authorizedDirections &= ~(Directions.Down | Directions.Left);
            }
            
            
            //We verify the path head is not going in a cell he already was before
            if (pathHead.y != m_mazeHeight - 1 && authorizedDirections.HasFlag(Directions.Up)) {
                //The position above the path head
                Vector2 expectedPos = new Vector2(pathHead.x, pathHead.y+1);
                for (int i = 0; i < path.Count; i++) {
                    if (path[i] == expectedPos) {
                        //If we already visited the cell above us, we remove it from our choices of directions
                        authorizedDirections &= ~Directions.Up;
                        i = path.Count;
                    }
                }
            }
            if (pathHead.x != m_mazeWidth-1 && authorizedDirections.HasFlag(Directions.Right)) {
                //The position at the right of the path head
                Vector2 expectedPos = new Vector2(pathHead.x+1, pathHead.y);
                for (int i = 0; i < path.Count; i++) {
                    if (path[i] == expectedPos) {
                        //If we already visited the cell on our right, we remove it from our choices of directions
                        authorizedDirections &= ~Directions.Right;
                        i = path.Count;
                    }
                }
            }
            if (pathHead.y != 0 && authorizedDirections.HasFlag(Directions.Down)) {
                //The position under the path head
                Vector2 expectedPos = new Vector2(pathHead.x, pathHead.y-1);
                for (int i = 0; i < path.Count; i++) {
                    if (path[i] == expectedPos) {
                        //If we already visited the cell under us, we remove it from our choices of directions
                        authorizedDirections &= ~Directions.Down;
                        i = path.Count;
                    }
                }
            }
            if (pathHead.x != 0 && authorizedDirections.HasFlag(Directions.Left)) {
                //The position at the left of the path head
                Vector2 expectedPos = new Vector2(pathHead.x-1, pathHead.y);
                for (int i = 0; i < path.Count; i++) {
                    if (path[i] == expectedPos) {
                        //If we already visited the cell on our left, we remove it from our choices of directions
                        authorizedDirections &= ~Directions.Left;
                        i = path.Count;
                    }
                }
            }

            if (authorizedDirections == Directions.None) {
                //If we end up here, it means the path head is stuck in a dead end it created itself
                //In this case, we're gonna force him a way out, otherwise it would stuck the code in an infinite loop
                if (pathHead.x != m_mazeWidth - 1) {
                    //We force him to go right if it's not facing the right wall already
                    authorizedDirections = Directions.Right;
                }
                else if (pathHead.y != 0) {
                    //If it faces the right wall, we force him to go down if it's not facing the down wall already
                    authorizedDirections = Directions.Down;
                }
                else { Debug.LogError("How is that even possible ?! The algorithm is going crazy if you see this error, contact Blue immediatly !"); }
            }
            
            //We select a random direction between all the ones that are authorized by the algorithm above
            Directions removedDirection = RandomDirectionBetween(authorizedDirections);
            
            //Here, we remove a wall in a random direction to the cell we're currently on
            m_maze[pathHead.y, pathHead.x] &= ~removedDirection;

            //We move the path head according to the direction we take and remove the wall on its passage
            if (removedDirection == Directions.Up) {
                pathHead.y++;
                m_maze[pathHead.y, pathHead.x] &= ~Directions.Down;
            }
            else if (removedDirection == Directions.Down) {
                pathHead.y--;
                m_maze[pathHead.y, pathHead.x] &= ~Directions.Up;
            }
            else if (removedDirection == Directions.Left) {
                pathHead.x--;
                m_maze[pathHead.y, pathHead.x] &= ~Directions.Right;
            }
            else if (removedDirection == Directions.Right) {
                pathHead.x++;
                m_maze[pathHead.y, pathHead.x] &= ~Directions.Left;
            }
            else {
                Debug.LogError("The path of the maze is malfunctioning, contact Blue if this error occurs");
            }
            
            //Debug.Log($"PATHHEAD :  X : {pathHead.x}        Y : {pathHead.y}");
        }
    }

    /// <summary>
    /// Is using the enum Directions and can return a random direction in a pool of directions defined by p_authorizedDirections
    /// </summary>
    /// <param name="p_authorizedDirections">
    /// The authorized return values, it can contains multiples directions
    /// Ex : 0b0000_1100 allow Right and Down as a return value
    /// </param>
    /// <returns>Returns a random direction in a pool of directions defined by p_authorizedDirections</returns>
    private Directions RandomDirectionBetween(Directions p_authorizedDirections) {
        if (p_authorizedDirections == Directions.None) {
            Debug.LogError("No authorized directions for p_authorizedDirections, it won't work dumbass");
            return Directions.None;
        }
        
        //We convert a byte that contains multiple directions in a List that contains multiple uniques directions in order to pick one randomly
        List<Directions> possibleOutcome = new List<Directions>();
        if (p_authorizedDirections.HasFlag(Directions.Up)) {
            possibleOutcome.Add(Directions.Up);
        }
        if (p_authorizedDirections.HasFlag(Directions.Down)) {
            possibleOutcome.Add(Directions.Down);
        }
        if (p_authorizedDirections.HasFlag(Directions.Right)) {
            possibleOutcome.Add(Directions.Right);
        }
        if (p_authorizedDirections.HasFlag(Directions.Left)) {
            possibleOutcome.Add(Directions.Left);
        }

        return possibleOutcome[Random.Range(0,possibleOutcome.Count)];
    }

    // Update is called once per frame
    void Update() {
        
        float horizontalAxis = Input.GetAxis("Horizontal");
        float verticalAxis = Input.GetAxis("Vertical");
        bool selectorValidation = Input.GetKeyDown(KeyCode.Joystick1Button0);

        if (!m_hasMoved && horizontalAxis < -m_limitPosition || horizontalAxis > m_limitPosition || verticalAxis >m_limitPosition || verticalAxis < -m_limitPosition) {
            
            Directions attemptedMovement = Directions.None;
            
            //We first stocks the way the player wants to go if he's not blocked by the limits of the maze
            if (!m_hasMoved && horizontalAxis < -m_limitPosition && m_selector.x > 0) {
                attemptedMovement = Directions.Left;
                m_hasMoved = true;
            }
            else if (!m_hasMoved && horizontalAxis > m_limitPosition && m_selector.x < m_maze.GetLength(1) - 1) {
                attemptedMovement = Directions.Right;
                m_hasMoved = true;
            }
            else if (!m_hasMoved && verticalAxis > m_limitPosition && m_selector.y < m_maze.GetLength(0) - 1) {
                attemptedMovement = Directions.Up;
                m_hasMoved = true;
            }
            else if (!m_hasMoved && verticalAxis < -m_limitPosition && m_selector.y > 0) {
                attemptedMovement = Directions.Down;
                m_hasMoved = true;
            }

            //First we verify the player has no wall blocking the way he wants to go;
            if (attemptedMovement == Directions.None || m_maze[m_selector.y, m_selector.x].HasFlag(attemptedMovement)) {
                Debug.Log("Nah bro, you cannot go this way");
                Handheld.Vibrate();
            }
            else {
                //If the movement is not blocked by a wall, we update the selector coordinates according to the wanted direction
                switch (attemptedMovement) {
                    case Directions.Left:
                        m_selector.x--;
                        break;
                    case Directions.Right:
                        m_selector.x++;
                        break;
                    case Directions.Up:
                        m_selector.y++;
                        break;
                    case Directions.Down:
                        m_selector.y--;
                        break;
                }

                //Then, we update the visual representation for the player
                SetRectPosition(m_player, m_selector.x, m_selector.y);
            }

            Debug.Log($"X : {m_selector.x}        Y : {m_selector.y}");
        }
        
        //Joystick se recentre sur la manette
        if (horizontalAxis < m_limitPosition && horizontalAxis > -m_limitPosition && verticalAxis < m_limitPosition && verticalAxis > -m_limitPosition)
        {
            m_hasMoved = false;
        }
        
        //Win verification
        if (m_selector.x == m_mazeWidth - 1 && m_selector.y == 0) {
            Win();
        }
        
        //Sortie du subPuzzle en cas de changement de personnage
        if (m_interactDetection.m_isInSubPuzzle && Input.GetKeyDown(m_inputs.inputMonster) || Input.GetKeyDown(m_inputs.inputRobot))
        {
            if(m_interactDetection.enabled)m_interactDetection.PuzzleDeactivation();
            gameObject.SetActive(false);
        }
        
    }

    /// <summary>
    /// Place correctly an element with its rect transform
    /// </summary>
    /// <param name="p_o">The game object you want to move</param>
    /// <param name="p_x">Its X coordinate</param>
    /// <param name="p_y">Its Y coordinate</param>
    private void SetRectPosition(GameObject p_o, int p_x, int p_y) {
        if (p_o.TryGetComponent(out RectTransform goRect)) {
            goRect.anchorMin = new Vector2(m_offset * p_x, m_offset * p_y);
            goRect.anchorMax = new Vector2(m_offset * (p_x+1), m_offset * (p_y+1));

            goRect.localPosition = Vector3.zero;

            goRect.anchoredPosition = Vector2.zero;
        }
    }
    
    /// <summary>
    /// Resize the current GameObject (must be a panel) in order to be a square without going out of the screen
    /// </summary>
    private void SquarePanelToScreen()
    {
        if (gameObject.TryGetComponent(out RectTransform thisRect)) 
        {
            thisRect.anchorMax = new Vector2(0.5f, 0.5f);
            thisRect.anchorMin = new Vector2(0.5f, 0.5f);
			
            if (Screen.width >= Screen.height) {
                thisRect.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, Screen.height);
                thisRect.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, Screen.height);
            } 
            else {
                Debug.Log("Dang it, that's a weird monitor you got there");
                thisRect.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, Screen.width);
                thisRect.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, Screen.width);
            }
            //Debug.Log(Screen.height);
        } 
        else {
            Debug.LogError ("JEEZ ! THIS SCRIPT IS MEANT TO BE ON A PANEL NOT A RANDOM GAMEOBJECT ! GAME DESIGNER DO YOUR JOB !");
        }
    }


    private void Win() {
        Debug.Log("IT'S A WIN !");
        
        m_interactDetection.m_achieved = true;  //le joueur est arrivé au bout
        
        if(m_interactDetection.enabled) m_interactDetection.PuzzleDeactivation();
        gameObject.SetActive(false);
    }
	
	
    /// <summary>
    /// Is called when this gameObject is setActive(false)
    /// Is used to destroy everything it created
    /// </summary>
    void OnDisable()
    {

        // https://memegenerator.net/instance/44816816/plotracoon-we-shall-destroy-them-all
        //As all the gameobjects we instantiated are child of this gameobject, we just have to erase all the children of this
        foreach(Transform child in gameObject.transform) {
            Destroy(child.gameObject);
        }
    }
}
