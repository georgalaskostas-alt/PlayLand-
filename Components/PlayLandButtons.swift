import SwiftUI

/// The filled, capsule-shaped look used for primary actions ("Continue",
/// "Start Chapter", "Unlock"). Prefer `PlayLandPrimaryButton` unless you
/// need a custom label (icon + text, etc.), in which case apply this
/// style directly to your own `Button`.
struct PlayLandButtonStyle: ButtonStyle {
    var color: Color = PlayLandColors.leafGreen

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 36)
            .padding(.vertical, 14)
            .frame(minHeight: PlayLandMetrics.minTouchTarget)
            .background(color)
            .clipShape(Capsule())
            .shadow(color: color.opacity(0.4), radius: 6, y: 3)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(PlayLandAnimation.quick, value: configuration.isPressed)
    }
}

/// A lighter, lower-emphasis look for secondary actions ("Clear", "Close").
struct PlayLandSecondaryButtonStyle: ButtonStyle {
    var color: Color = PlayLandColors.secondaryText

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(color)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .frame(minHeight: PlayLandMetrics.minTouchTarget)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(PlayLandAnimation.quick, value: configuration.isPressed)
    }
}

/// A full-width, multiline-friendly style used for story/chapter choice
/// buttons, where the label text length varies scene to scene.
///
/// `.fixedSize(horizontal: false, vertical: true)` before the width/height
/// frames is what lets a long translation wrap onto multiple lines and grow
/// the button taller, instead of being squeezed onto — and truncated on —
/// one line at whatever height `minHeight` happens to specify.
struct PlayLandChoiceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(minHeight: PlayLandMetrics.minTouchTarget)
            .background(PlayLandColors.skyBlue.opacity(configuration.isPressed ? 0.75 : 0.9))
            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(PlayLandAnimation.quick, value: configuration.isPressed)
    }
}

/// The app's standard call-to-action button: a colored capsule with a tap sound.
struct PlayLandPrimaryButton: View {
    let title: String
    var color: Color = PlayLandColors.leafGreen
    let action: () -> Void

    var body: some View {
        Button(action: {
            AudioManager.shared.play(.buttonTap)
            action()
        }) {
            Text(title)
        }
        .buttonStyle(PlayLandButtonStyle(color: color))
    }
}

/// A lower-emphasis companion to `PlayLandPrimaryButton`.
struct PlayLandSecondaryButton: View {
    let title: String
    var color: Color = PlayLandColors.secondaryText
    let action: () -> Void

    var body: some View {
        Button(action: {
            AudioManager.shared.play(.buttonTap)
            action()
        }) {
            Text(title)
        }
        .buttonStyle(PlayLandSecondaryButtonStyle(color: color))
    }
}
