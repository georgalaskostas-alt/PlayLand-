import SwiftUI

struct DinoSortGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🦖 Dino Sort").font(.title).fontWeight(.bold)
            Text("Sort by type!").font(.headline).foregroundColor(.gray)
            
            Image(systemName: "arrow.up.arrow.down").font(.system(size: 100)).foregroundColor(.blue)
            Text("Herbivores vs Carnivores!").font(.headline)
            
            Button(action: {
                progressManager.completeGame("dino_sort", stars: 3)
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
