import SwiftUI

/// Readable storybook narration bubble. The type is deliberately larger than
/// normal body copy because this screen is consumed primarily by young readers.
struct CharacterDialogueBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 19, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .lineSpacing(5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 17)
            .padding(.vertical, 15)
            .background(Color.black.opacity(0.68))
            .overlay(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium).stroke(.white.opacity(0.14), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
    }
}
