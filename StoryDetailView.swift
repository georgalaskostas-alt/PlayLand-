import SwiftUI

struct StoryDetailView: View {
    let storyId: String
    @EnvironmentObject var progressManager: ProgressViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("📖 Story: \(storyId)").font(.title).fontWeight(.bold)
            
            Text("Story content coming soon!").font(.headline).foregroundColor(.gray)
            
            Button(action: {
                progressManager.completeStory(storyId)
                dismiss()
            }) {
                Text("Complete Story").font(.headline).foregroundColor(.white)
                    .padding(.horizontal, 40).padding(.vertical, 15)
                    .background(Color.green).cornerRadius(25)
            }
            Spacer()
        }.padding()
    }
}
