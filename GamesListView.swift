import SwiftUI

struct GamesListView: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    
    let games = [
        Game(id: "letter_recognition", title: "Letter Recognition", description: "Learn letters!", iconImageName: "icon_letter_game"),
        Game(id: "word_matching", title: "Word Matching", description: "Match words!", iconImageName: "icon_word_match"),
        Game(id: "word_search", title: "Word Search", description: "Find words!", iconImageName: "icon_word_search"),
        Game(id: "word_scramble", title: "Word Scramble", description: "Unscramble!", iconImageName: "icon_word_scramble"),
        Game(id: "memory_game", title: "Memory Game", description: "Train memory!", iconImageName: "icon_memory_game")
    ]

    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("🎮 Learning Games")) {
                    ForEach(games) { game in
                        NavigationLink(destination: gameView(for: game)) {
                            HStack {
                                Image(game.iconImageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(12)
                                    .shadow(radius: 3)

                                
                                VStack(alignment: .leading) {
                                    Text(game.title)
                                        .font(.headline)
                                    Text(game.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    if progressManager.isGameCompleted(game.id) {
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            Text("Completed!")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                if progressManager.isGameCompleted(game.id) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .navigationTitle("PlayLand")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    @ViewBuilder
    private func gameView(for game: Game) -> some View {
        switch game.id {
        case "letter_recognition":
            LetterRecognitionGame()
        case "word_matching":
            WordMatchingGame()
        case "word_search":
            WordSearchGame()
        case "word_scramble":
            WordScrambleGame()
        case "memory_game":
            MemoryGame()
        default:
            Text("Game coming soon!")
        }
    }
}

struct Game: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
}
