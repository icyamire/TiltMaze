import SwiftUI

struct SensitivityControlView: View {
    @Binding var viscosity: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            Text("👈 Red Sluggish / Purple Sluggish 👉")
                .font(.footnote)
                .bold()
                .foregroundColor(.secondary)
                
            HStack(spacing: 15) {
                Image(systemName: "circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                
                Slider(value: $viscosity, in: 0...1)
                    .accentColor(.blue)
                
                Image(systemName: "circle.fill")
                    .foregroundColor(.purple)
                    .font(.title2)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal, 40)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}
