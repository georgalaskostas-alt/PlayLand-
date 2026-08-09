import SwiftUI

struct WordMatchingGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Word Matching").font(.title).fontWeight(.bold)
            Text("🖼️ Match picture with word!").font(.headline).foregroundColor(.gray)
            
            VStack(spacing: 15) {
                ForEach(["🍎 Apple", "⚽ Ball", "🐱 Cat"], id: \.self) { item in
                    Text(item).font(.title2).padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1)).cornerRadius(15)
                }
            }
            
            Button(action: {
                progressManager.completeGame("word_matching", stars: 3)
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
