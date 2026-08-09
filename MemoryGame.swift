mport SwiftUI

struct MemoryGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Memory Game").font(.title).fontWeight(.bold)
            Text("🧠 Match pairs!").font(.headline).foregroundColor(.gray)
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 4), spacing: 15) {
                ForEach(0..<16) { _ in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(Image(systemName: "questionmark").font(.title2).foregroundColor(.blue))
                }
            }
            
            Button(action: {
                progressManager.completeGame("memory_game", stars: 3)
                dismiss()
            }) {
                Text("Complete!").font(.headline).foregroundColor(.white)
                    .padding(.horizontal, 40).padding(.vertical, 15)
                    .background(Color.green).cornerRadius(25)
            }
            Spacer()
        }.padding()
    }
}
