import SwiftUI

struct HUDOverlayView: View {
    var currentLevel: Int
    var isBallAReady: Bool
    var isBallCReady: Bool
    var isWin: Bool
    var elapsedTime: TimeInterval
    
    // Formatting the time
    private var timeString: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Level \(currentLevel)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(timeString)
                    .font(.title2.monospacedDigit())
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)
                
            HStack {
                StatusBadge(title: "Red Ready", isReady: isBallAReady, activeColor: .red)
                Spacer()
                StatusBadge(title: "Purple Ready", isReady: isBallCReady, activeColor: .purple)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            if isWin {
                Spacer()
                Text("SUCCESS!")
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .foregroundColor(.green)
                    .shadow(color: .white, radius: 10, x: 0, y: 0)
                Spacer()
            }
        }
    }
}

struct StatusBadge: View {
    var title: String
    var isReady: Bool
    var activeColor: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(isReady ? activeColor : Color.gray.opacity(0.5))
                .frame(width: 15, height: 15)
                .shadow(color: isReady ? activeColor : .clear, radius: 5, x: 0, y: 0)
            
            Text(title)
                .font(.headline)
                .foregroundColor(isReady ? .primary : .secondary)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
