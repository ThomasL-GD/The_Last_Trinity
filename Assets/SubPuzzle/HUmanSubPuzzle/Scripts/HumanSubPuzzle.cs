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

    private Selector m_selector = new Selector(0,0);

    [SerializeField] [Tooltip("The height of the maze (unit : cells)")] public int m_mazeHeight = 5;
    [SerializeField] [Tooltip("The width of the maze (unit : cells)")] public int m_mazeWidth = 5;
    [SerializeField] [Tooltip("The number of random removed walls (Warning ! This function can remove walls that are already removed by the base algorithm) ")] public int m_wallsToRemove = 5;
    /*Contains every cell of the maze and if each cell have a wall above, under, on the right or on the left of itself*/private Directions[,] m_maze = null;
    [SerializeField] [Tooltip("Décalage du prefab sur l'axe X")] private float m_offsetX = 4.0f;
    [SerializeField] [Tooltip("Décalage du prefab sur l'axe Y")] private float m_offsetY = 4.0f;

    [Header("Prefabs for visual representation")]
    [SerializeField] [Tooltip("For debug only")] private GameObject m_prefabBG = null;
    [SerializeField] [Tooltip("For debug only")] private GameObject m_prefabUp = null;
    [SerializeField] [Tooltip("For debug only")] private GameObject m_prefabLeft = null;
    [SerializeField] [Tooltip("For debug only")] private GameObject m_prefabRight = null;
    [SerializeField] [Tooltip("For debug only")] private GameObject m_prefabDown = null;
    
    
    /// <summary>
    /// OnEnable is called once each time the Game Object is enabled
    /// In our case, it will initialize the maze
    /// </summary>
    void OnEnable() {

        if (m_mazeHeight < 2 || m_mazeWidth < 2) {
            Debug.LogError("Invalid size of the maze ! each dimension must be 2 or more cell long");
        }
        if (m_wallsToRemove >= m_mazeHeight * m_mazeWidth * 4) {
            Debug.LogWarning("Warning ! You want to remove to many random walls from the maze, it's gonna be either way too easy or completely fucked up");
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
            
            //We select a random direction and a random tile to break a wall
            Directions removedDirection = RandomDirectionBetween(Directions.All);
            Selector select = new Selector(Random.Range(0, m_maze.GetLength(1)), Random.Range(0, m_maze.GetLength(0)));
            
            m_maze[select.y, select.x] &= ~removedDirection;
            
            //Once we removed a wall, we make sure the adjacent cell (if it exists) will have its opposite wall removed as well
            if (removedDirection == Directions.Up && select.y != 0) {
                m_maze[select.y-1, select.x] &= ~Directions.Down;
            }
            else if (removedDirection == Directions.Down && select.y != m_mazeHeight - 1) {
                m_maze[select.y+1, select.x] &= ~Directions.Up;
            }
            else if (removedDirection == Directions.Left && select.x != 0) {
                m_maze[select.y, select.x-1] &= ~Directions.Right;
            }
            else if (removedDirection == Directions.Right && select.x != m_mazeWidth - 1) {
                m_maze[select.y, select.x+1] &= ~Directions.Left;
            }
        }
        
        
        //We just fill the borders with walls to avoid the player to escape
         for (int i = 0; i < m_maze.GetLength(0); i++) {
             for (int j = 0; j < m_maze.GetLength(1); j++) {
                 //Up Border
                 if (i == 0) m_maze[i, j] |= Directions.Up;
                 
                 //Down Border
                 if (i == m_maze.GetLength(0) - 1) m_maze[i, j] |= Directions.Down;
                 
                 //Left Border
                 if (j == 0) m_maze[i, j] |= Directions.Left;
                 
                 //Right Border
                 if (j == m_maze.GetLength(1) - 1) m_maze[i, j] |= Directions.Right;
             }
         }


        //Visual representation
        GameObject emptyContainer = new GameObject("PiecesContainer");
        GameObject container = Instantiate(emptyContainer);
        
        for (int i = 0; i < m_maze.GetLength(0); i++) {
            for (int j = 0; j < m_maze.GetLength(1); j++) {

                transform.position = new Vector3(0 + j * m_offsetX, 0 - i * m_offsetY, 0);
                Instantiate(m_prefabBG, new Vector3(transform.position.x, transform.position.y, transform.position.z + 0.5f), transform.rotation, container.transform);

                if (m_maze[i, j].HasFlag(Directions.Up)) {
                    Instantiate(m_prefabUp, transform.position, transform.rotation, container.transform);
                }
                if (m_maze[i, j].HasFlag(Directions.Down)) {
                    Instantiate(m_prefabDown, transform.position, transform.rotation, container.transform);
                }
                if (m_maze[i, j].HasFlag(Directions.Left)) {
                    Instantiate(m_prefabLeft, transform.position, transform.rotation, container.transform);
                }
                if (m_maze[i, j].HasFlag(Directions.Right)) {
                    Instantiate(m_prefabRight, transform.position, transform.rotation, container.transform);
                }
                
            }
        }
    }

    /// <summary>
    /// Will calculate a possible way to solve the maze and destroy every wall in its way in order to let the player have at least one possible solution to solve the maze
    /// </summary>
    private void GenerateMazeSolution() {
        
        // We create a path from the beginning to the end that will create holes in the maze in order to make sure there's at least one possible solution for the player;
        //We create a path head that will move in the maze and initialize it in 0,0
        Selector pathHead = new Selector(0, 0);
        List<Vector2> path = new List<Vector2>();
        
        while (!(pathHead.x == m_mazeWidth - 1 && pathHead.y == m_mazeHeight - 1)) {

            Directions authorizedDirections = Directions.All;
            path.Add(new Vector2(pathHead.x, pathHead.y));

            //We forbid some movement when the path head is on a border
            if (pathHead.x == 0) {
                //The Left border forbids left & up
                authorizedDirections &= ~(Directions.Left | Directions.Up);
            }
            if (pathHead.y == 0) {
                //The Up border forbids left & up
                authorizedDirections &= ~(Directions.Left | Directions.Up);
            }
            if (pathHead.x == m_mazeWidth - 1) {
                //The Right border forbids right & up
                authorizedDirections &= ~(Directions.Right | Directions.Up);
            }
            if (pathHead.y == m_mazeHeight - 1) {
                //The Down border forbids down & left
                authorizedDirections &= ~(Directions.Down | Directions.Left);
            }
            
            
            //We verify the path head is not going in a cell he already was before
            if (pathHead.y != 0 && authorizedDirections.HasFlag(Directions.Up)) {
                //The position above the path head
                Vector2 expectedPos = new Vector2(pathHead.x, pathHead.y-1);
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
            if (pathHead.y != m_mazeHeight - 1 && authorizedDirections.HasFlag(Directions.Down)) {
                //The position under the path head
                Vector2 expectedPos = new Vector2(pathHead.x, pathHead.y+1);
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
                else if (pathHead.y != m_mazeHeight - 1) {
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
                pathHead.y--;
                m_maze[pathHead.y, pathHead.x] &= ~Directions.Down;
            }
            else if (removedDirection == Directions.Down) {
                pathHead.y++;
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

        if (Input.GetKeyDown(KeyCode.LeftArrow) || Input.GetKeyDown(KeyCode.RightArrow) || Input.GetKeyDown(KeyCode.UpArrow) || Input.GetKeyDown(KeyCode.DownArrow)) {

            //déplacement du sélecteur
            //Déplacement a gauche si position X sélecteur > position  X  première prefab instanciée
            if (Input.GetKeyDown(KeyCode.LeftArrow) && m_selector.x > 0) {
                m_selector.x--;
            }
            //Déplacement à droite si position  X sélecteur  < valeur largeur tableau prefab        // -1 parce que départ de 0
            else if (Input.GetKeyDown(KeyCode.RightArrow) && m_selector.x < m_maze.GetLength(1) - 1) {
                m_selector.x++;
            }
            //Déplacement en haut si position Y sélecteur < position Y première prefab
            else if (Input.GetKeyDown(KeyCode.UpArrow) && m_selector.y > 0) {
                m_selector.y--;
            }
            //Déplacement en bas si position Y sélecteur > valeur dernière prefab du tableau prefab       // -1 parce que départ de 0
            else if (Input.GetKeyDown(KeyCode.DownArrow) && m_selector.y < m_maze.GetLength(0) - 1) {
                m_selector.y++;
            }
        }
    }
}
