import Foundation

class MazeGenerator2D {
    static func generate(width: Int, height: Int) -> MazeGrid {
        var grid = MazeGrid(width: width, height: height)
        var stack: [(Int, Int)] = []
        
        let startX = Int.random(in: 0..<width)
        let startY = Int.random(in: 0..<height)
        
        grid.cells[startX][startY].visited = true
        stack.append((startX, startY))
        
        let directions = [(0, -1), (1, 0), (0, 1), (-1, 0)] // Top, Right, Bottom, Left
        
        while let (currentX, currentY) = stack.last {
            var unvisitedNeighbors: [(Int, Int, Int)] = []
            
            for (i, dir) in directions.enumerated() {
                let nx = currentX + dir.0
                let ny = currentY + dir.1
                
                if nx >= 0 && nx < width && ny >= 0 && ny < height && !grid.cells[nx][ny].visited {
                    unvisitedNeighbors.append((nx, ny, i))
                }
            }
            
            if unvisitedNeighbors.isEmpty {
                stack.removeLast()
            } else {
                let next = unvisitedNeighbors.randomElement()!
                let nx = next.0
                let ny = next.1
                let dirIndex = next.2
                
                grid.cells[nx][ny].visited = true
                
                if dirIndex == 0 { // Top
                    grid.cells[currentX][currentY].topWall = false
                    grid.cells[nx][ny].bottomWall = false
                } else if dirIndex == 1 { // Right
                    grid.cells[currentX][currentY].rightWall = false
                    grid.cells[nx][ny].leftWall = false
                } else if dirIndex == 2 { // Bottom
                    grid.cells[currentX][currentY].bottomWall = false
                    grid.cells[nx][ny].topWall = false
                } else if dirIndex == 3 { // Left
                    grid.cells[currentX][currentY].leftWall = false
                    grid.cells[nx][ny].rightWall = false
                }
                
                stack.append((nx, ny))
            }
        }
        
        // Randomly remove a few extra walls (loops) to make it slightly easier
        let extraRemovals = (width * height) / 10
        for _ in 0..<extraRemovals {
            let rx = Int.random(in: 1..<width-1)
            let ry = Int.random(in: 1..<height-1)
            
            if Bool.random() {
                grid.cells[rx][ry].rightWall = false
                grid.cells[rx+1][ry].leftWall = false
            } else {
                grid.cells[rx][ry].bottomWall = false
                grid.cells[rx][ry+1].topWall = false
            }
        }
        
        return grid
    }
}
