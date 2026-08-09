mport SwiftUI

struct DinoDigGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🦖 Dino Dig").font(.title).fontWeight(.bold)
            Text("⛏️ Excavate fossils!").font(.headline).foregroundColor(.gray)
            
            Image(systemName: "shovel.fill").font(.system(size: 100)).foregroundColor(.brown)
            Text("Tap to dig!").font(.headline)
            
            Button(action: {
                progressManager.completeGame("dino_dig", stars: 3)
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
