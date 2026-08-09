import SwiftUI

struct DinoMatchGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🦖 Dino Match").font(.title).fontWeight(.bold)
            Text("Match dinosaurs!").font(.headline).foregroundColor(.gray)
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 15) {
                ForEach(0..<12) { _ in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(Image(systemName: "leaf.fill").font(.title).foregroundColor(.green))
                }
            }
            
            Button(action: {
                progressManager.completeGame("dino_match", stars: 3)
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
