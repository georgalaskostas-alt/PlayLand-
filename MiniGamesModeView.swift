import SwiftUI

struct MiniGamesModeView: View {
    let miniGames = [
        MiniGame(id: "memory", title: "Memory Match", description: "Match pairs of cards", icon: "brain.head.profile", color: .purple),
        MiniGame(id: "word", title: "Word Puzzle", description: "Unscramble the words", icon: "text.alignleft", color: .blue),
        MiniGame(id: "math", title: "Math Challenge", description: "Solve simple math", icon: "plus.circle.fill", color: .green)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎮 Mini-Games")
                .font(.title)
                .fontWeight(.bold)
            
            List {
                ForEach(miniGames) { game in
                    NavigationLink(destination: miniGameView(for: game)) {
                        HStack {
                            Image(systemName: game.icon)
                                .font(.title2)
                                .foregroundColor(game.color)
                                .frame(width: 50, height: 50)
                                .background(game.color.opacity(0.2))
                                .cornerRadius(10)
                            
                            VStack(alignment: .leading) {
                                Text(game.title)
                                    .font(.headline)
                                Text(game.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Mini-Games")
    }
    
    @ViewBuilder
    private func miniGameView(for game: MiniGame) -> some View {
        switch game.id {
        case "memory":
            MemoryMiniGame()
        case "word":
            WordMiniGame()
        case "math":
            MathMiniGame()
        default:
            Text("Coming soon!")
        }
    }
}

struct MiniGame: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
}

// Memory Mini Game
struct MemoryMiniGame: View {
    @State private var cards = ["A", "A", "B", "B", "C", "C"]
    @State private var flippedCards: [Int] = []
    @State private var matchedPairs: Set<Int> = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Find matching pairs!")
                .font(.headline)
            
            Text("Pairs: \(matchedPairs.count)/3")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 15) {
                ForEach(Array(cards.enumerated()), id: \.offset) { index, card in
                    Button(action: {
                        flipCard(index)
                    }) {
                        Text(flippedCards.contains(index) || matchedPairs.contains(index) ? card : "?")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                            .frame(width: 80, height: 80)
                            .background(flippedCards.contains(index) || matchedPairs.contains(index) ? Color.green : Color.blue.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(flippedCards.contains(index) || matchedPairs.contains(index))
                }
            }
            
            if matchedPairs.count == 3 {
                Text("🎉 You Won!")
                    .font(.title)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .navigationTitle("Memory Match")
    }
    
    private func flipCard(_ index: Int) {
        if flippedCards.count < 2 && !flippedCards.contains(index) {
            flippedCards.append(index)
            
            if flippedCards.count == 2 {
                checkMatch()
            }
        }
    }
    
    private func checkMatch() {
        let firstIndex = flippedCards[0]
        let secondIndex = flippedCards[1]
        
        if cards[firstIndex] == cards[secondIndex] {
            matchedPairs.insert(firstIndex)
            matchedPairs.insert(secondIndex)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            flippedCards.removeAll()
        }
    }
}

// Word Mini Game
struct WordMiniGame: View {
    @State private var scrambledWord = "ELPAP"
    @State private var answer = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Unscramble the word!")
                .font(.headline)
            
            Text(scrambledWord)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            TextField("Your answer", text: $answer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.alphabet)
            
            Button(action: {
                // Check answer
            }) {
                Text("Check")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(Color.green)
                    .cornerRadius(25)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Word Puzzle")
    }
}

// Math Mini Game
struct MathMiniGame: View {
    @State private var num1 = Int.random(in: 1...10)
    @State private var num2 = Int.random(in: 1...10)
    @State private var answer = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Solve the math!")
                .font(.headline)
            
            Text("\(num1) + \(num2) = ?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            TextField("Your answer", text: $answer)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                // Check answer
            }) {
                Text("Check")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(Color.green)
                    .cornerRadius(25)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Math Challenge")
    }
}
