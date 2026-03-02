import Foundation

struct MazeCell {
    var x: Int
    var y: Int
    var topWall: Bool = true
    var bottomWall: Bool = true
    var leftWall: Bool = true
    var rightWall: Bool = true
    var visited: Bool = false
}

struct MazeGrid {
    let width: Int
    let height: Int
    var cells: [[MazeCell]]
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        cells = Array(repeating: Array(repeating: MazeCell(x: 0, y: 0), count: height), count: width)
        for x in 0..<width {
            for y in 0..<height {
                cells[x][y] = MazeCell(x: x, y: y)
            }
        }
    }
}
