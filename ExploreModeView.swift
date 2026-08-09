import SwiftUI

struct ExploreModeView: View {
    @State private var playerPosition = CGPoint(x: 150, y: 300)
    @State private var showingDialogue = false
    @State private var dialogueText = ""
    
    var body: some View {
        ZStack {
            // Background
            Image("forest_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Interactive Objects
            VStack {
                HStack {
                    // Tree
                    Button(action: {
                        dialogueText = "This is an old oak tree. It provides shade and fruits!"
                        showingDialogue = true
                    }) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    // Rock
                    Button(action: {
                        dialogueText = "A shiny rock! Maybe there are crystals inside?"
                        showingDialogue = true
                    }) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 100)
                
                Spacer()
            }
            
            // Player (Babis)
            Image("babis_dinosaur_side")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .position(playerPosition)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            playerPosition = value.location
                        }
                )
            
            // Companion (Kotsifi)
            Image("kotsifi_bird_side")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .position(x: playerPosition.x + 60, y: playerPosition.y - 40)

            // Dialogue
            if showingDialogue {
                VStack {
                    Spacer()
                    
                    Text(dialogueText)
                        .font(.headline)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(15)
                        .padding()
                    
                    Button("Close") {
                        showingDialogue = false
                    }
                    .padding(.bottom, 50)
                }
            }
            
            // Controls
            VStack {
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        // Move up
                        playerPosition.y -= 20
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                    }
                }
                
                HStack(spacing: 20) {
                    Button(action: {
                        playerPosition.x -= 20
                    }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                    }
                    
                    Button(action: {
                        playerPosition.x += 20
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                    }
                }
                
                Button(action: {
                    playerPosition.y += 20
                }) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Explore")
    }
}
