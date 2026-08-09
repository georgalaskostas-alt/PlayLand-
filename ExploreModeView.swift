import SwiftUI

struct ExploreModeView: View {
    @State private var playerPosition = CGPoint(x: 150, y: 300)
    @State private var showingDialogue = false
    @State private var dialogueText = ""
    @State private var isNight = false
    @State private var showingFoxCave = false

    private let step: CGFloat = 24

    var body: some View {
        ZStack {
            Image(isNight ? "forest_background_night" : "forest_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: {
                        dialogueText = "This is an old oak tree. It gives shade and yummy fruit!"
                        showingDialogue = true
                    }) {
                        Text("🌳").font(.system(size: 60))
                    }

                    Spacer()

                    Button(action: {
                        dialogueText = "A shiny rock! Maybe there are crystals hiding underneath."
                        showingDialogue = true
                    }) {
                        Text("🪨").font(.system(size: 50))
                    }

                    Spacer()

                    Button(action: { showingFoxCave = true }) {
                        VStack(spacing: 4) {
                            Image("fox_cave_background")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            Text("Fox Cave")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.top, 90)
                .padding(.horizontal, 30)

                Spacer()
            }

            Image("kotsifi_bird_side")
                .resizable()
                .scaledToFit()
                .frame(width: 55, height: 55)
                .position(x: playerPosition.x + 55, y: playerPosition.y - 45)

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

            VStack {
                Spacer()
                HStack {
                    Button(action: { isNight.toggle() }) {
                        Text(isNight ? "☀️" : "🌙")
                            .font(.system(size: 28))
                            .padding(10)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding()
            }

            if showingDialogue {
                VStack {
                    Spacer()
                    Text(dialogueText)
                        .font(.headline)
                        .padding()
                        .background(Color.white.opacity(0.92))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding()

                    Button("Close") { showingDialogue = false }
                        .buttonStyle(PlayfulButtonStyle(color: PlayLandTheme.sunOrange))
                        .padding(.bottom, 60)
                }
            }

            dPad
        }
        .navigationTitle("Explore")
        .fullScreenCover(isPresented: $showingFoxCave) {
            FoxCaveDialogueView(isPresented: $showingFoxCave)
        }
    }

    private var dPad: some View {
        VStack {
            Spacer()
            VStack(spacing: 6) {
                arrowButton("▲") { playerPosition.y -= step }
                HStack(spacing: 40) {
                    arrowButton("◀") { playerPosition.x -= step }
                    arrowButton("▶") { playerPosition.x += step }
                }
                arrowButton("▼") { playerPosition.y += step }
            }
            .padding(.bottom, 30)
        }
    }

    private func arrowButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(symbol)
                .font(.title.bold())
                .foregroundColor(.white)
                .frame(width: 54, height: 54)
                .background(PlayLandTheme.sunOrange)
                .clipShape(Circle())
                .shadow(radius: 3)
        }
    }
}

struct FoxCaveDialogueView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Image("fox_cave_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.25).ignoresSafeArea())

            VStack {
                Spacer()

                Image("alepou_fox")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .shadow(radius: 6)

                Text("\"Shh, careful in here! I live nearby and I love visitors.\"")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.black.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(.horizontal)

                Button("Leave the cave") { isPresented = false }
                    .buttonStyle(PlayfulButtonStyle(color: PlayLandTheme.leafGreen))
                    .padding(.top, 10)
                    .padding(.bottom, 40)
            }
        }
    }
}
