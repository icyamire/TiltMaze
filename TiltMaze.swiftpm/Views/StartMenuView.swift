import SwiftUI

struct StartMenuView: View {
    @Binding var isGameActive: Bool
    @Binding var startingLevel: Int
    @Binding var selectedMode: GameMode
    
    var body: some View {
        ZStack {
            Color.green.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Text("TiltMaze")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .padding(.top, 50)
                
                Spacer()
                
                Picker("Control Mode", selection: $selectedMode) {
                    Text("Gravity Tilt").tag(GameMode.gravity)
                    Text("AR Head Control").tag(GameMode.arFace)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 40)
                
                Button(action: {
                    startingLevel = 1
                    isGameActive = true
                }) {
                    Text("Start from Level 1")
                        .font(.title2)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                
                VStack(spacing: 15) {
                    Text("Custom Level")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Stepper(value: $startingLevel, in: 1...15) {
                        Text("Start Level: \(startingLevel)")
                            .font(.title3)
                    }
                    .padding(.horizontal, 60)
                    
                    Button(action: {
                        isGameActive = true
                    }) {
                        Text("Start Custom Game")
                            .font(.title3)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.top, 20)
                
                
                Spacer()
            }
        }
    }
}
