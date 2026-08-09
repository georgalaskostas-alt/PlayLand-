import SwiftUI

struct DinoFarmGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🦖 Dino Farm").font(.title).fontWeight(.bold)
            Text("Care for baby dinos!").font(.headline).foregroundColor(.gray)
            
            Image(systemName: "house.fill").font(.system(size: 100)).foregroundColor(.orange)
            Text("Feed, clean, play!").font(.headline)
            
            Button(action: {
                progressManager.completeGame("dino_farm", stars: 3)
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
