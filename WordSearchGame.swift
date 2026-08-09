import SwiftUI

struct WordSearchGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Word Search").font(.title).fontWeight(.bold)
            Text("🔍 Find hidden words!").font(.headline).foregroundColor(.gray)
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 5), spacing: 10) {
                ForEach(0..<25) { _ in
                    Text(String("ABCDEFGHIJKLMNOPQRSTUVWXYZ".randomElement()!))
                        .font(.title2).frame(width: 50, height: 50)
                        .background(Color.blue.opacity(0.1)).cornerRadius(10)
                }
            }
            
            Button(action: {
                progressManager.completeGame("word_search", stars: 3)
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
