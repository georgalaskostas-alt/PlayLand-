import SwiftUI

struct WordScrambleGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Word Scramble").font(.title).fontWeight(.bold)
            Text("🔤 Unscramble letters!").font(.headline).foregroundColor(.gray)
            
            VStack(spacing: 15) {
                HStack(spacing: 10) {
                    ForEach(["A", "P", "P", "L", "E"], id: \.self) { letter in
                        Text(letter).font(.title).fontWeight(.bold).padding()
                            .background(Color.orange.opacity(0.2)).cornerRadius(10)
                    }
                }
                TextField("Answer", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Button(action: {
                progressManager.completeGame("word_scramble", stars: 3)
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
