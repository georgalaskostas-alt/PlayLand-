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
            PlayLandBackground(imageName: isNight ? AppAssets.Backgrounds.forestNight : AppAssets.Backgrounds.forestDay, scrimOpacity: 0)

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
                            AppAssets.image(AppAssets.Backgrounds.foxCave)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusSmall))
                            Text("Fox Cave")
                                .font(PlayLandTypography.caption)
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

            AppAssets.image(AppAssets.Characters.kotsifiSide)
                .resizable()
                .scaledToFit()
                .frame(width: 55, height: 55)
                .position(x: playerPosition.x + 55, y: playerPosition.y - 45)

            AppAssets.image(AppAssets.Characters.babisSide)
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
                            .frame(minWidth: PlayLandMetrics.minTouchTarget, minHeight: PlayLandMetrics.minTouchTarget)
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
                        .font(PlayLandTypography.heading)
                        .padding()
                        .background(Color.white.opacity(0.92))
                        .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
                        .padding()

                    PlayLandPrimaryButton(title: "Close", color: PlayLandColors.sunOrange) {
                        showingDialogue = false
                    }
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
                .frame(width: PlayLandMetrics.primaryTouchTarget * 0.85, height: PlayLandMetrics.primaryTouchTarget * 0.85)
                .background(PlayLandColors.sunOrange)
                .clipShape(Circle())
                .shadow(radius: 3)
        }
    }
}

struct FoxCaveDialogueView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            PlayLandBackground(imageName: AppAssets.Backgrounds.foxCave, scrimOpacity: 0.25)

            VStack {
                Spacer()

                AppAssets.image(AppAssets.Characters.fox)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .shadow(radius: 6)

                CharacterDialogueBubble(text: "\"Shh, careful in here! I live nearby and I love visitors.\"")
                    .padding(.horizontal)

                PlayLandPrimaryButton(title: "Leave the cave", color: PlayLandColors.leafGreen) {
                    isPresented = false
                }
                .padding(.top, 10)
                .padding(.bottom, 40)
            }
        }
    }
}
