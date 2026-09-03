import SwiftUI
import PencilKit

struct ArtStudioExpandedHubView: View {
    @EnvironmentObject private var appSettings: AppSettings
    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text("🎨").font(.system(size: 54))
                Text(isGreek ? "Εργαστήριο Ζωγραφικής" : "Art Studio")
                    .font(.system(size: 30, weight: .black, design: .rounded))

                NavigationLink {
                    ArtStudioV4View()
                } label: {
                    card(emoji: "🖍️", title: isGreek ? "30 έτοιμα σκίτσα" : "30 ready drawings", subtitle: isGreek ? "Τα αναλυτικά σκίτσα που έχουμε ήδη." : "The detailed drawings already available.")
                }

                NavigationLink {
                    ArtStudioProceduralLibraryView(kind: .detailed)
                } label: {
                    card(emoji: "🏰", title: isGreek ? "100 αναλυτικά σχέδια" : "100 detailed drawings", subtitle: isGreek ? "Capybara, μονόκεροι, πριγκίπισσες, κάστρα, δράκοι, γοργόνες, δεινόσαυροι και άλλα — όλα σχεδιασμένα από κώδικα." : "Capybaras, unicorns, princesses, castles, dragons, mermaids, dinosaurs and more — all generated in code.")
                }

                NavigationLink {
                    ArtStudioProceduralLibraryView(kind: .simple)
                } label: {
                    card(emoji: "⭐️", title: isGreek ? "100 απλά σχέδια" : "100 simple drawings", subtitle: isGreek ? "Καρδιές, αστέρια, λουλούδια, πεταλούδες, απλοί μονόκεροι, ζωάκια, οχήματα και άλλα." : "Hearts, stars, flowers, butterflies, simple unicorns, animals, vehicles and more.")
                }
            }
            .padding(18)
        }
        .background(LinearGradient(colors: [.purple.opacity(0.18), .blue.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea())
        .navigationTitle(isGreek ? "Ζωγραφική" : "Drawing")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func card(emoji: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Text(emoji).font(.system(size: 42))
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.title3.weight(.black))
                Text(subtitle).font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.headline.weight(.bold)).foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 118)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}

enum ArtStudioProceduralKind: String, Identifiable {
    case detailed, simple
    var id: String { rawValue }
}

struct ArtStudioProceduralLibraryView: View {
    @EnvironmentObject private var appSettings: AppSettings
    let kind: ArtStudioProceduralKind
    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }

    private var titles: [ArtStudioDrawingTitle] {
        kind == .detailed ? ArtStudioProceduralCatalog.detailedTitles : ArtStudioProceduralCatalog.simpleTitles
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                ForEach(Array(titles.enumerated()), id: \.offset) { index, title in
                    NavigationLink {
                        ArtStudioProceduralCanvasView(kind: kind, drawingIndex: index)
                    } label: {
                        VStack(spacing: 8) {
                            ArtStudioProceduralPageView(index: kind == .detailed ? index : index + 100)
                                .frame(height: 110)
                                .padding(5)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            Text(isGreek ? title.gr : title.en)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.black)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(14)
        }
        .background(Color(red: 0.94, green: 0.92, blue: 0.88).ignoresSafeArea())
        .navigationTitle(kind == .detailed ? (isGreek ? "100 αναλυτικά" : "100 detailed") : (isGreek ? "100 απλά" : "100 simple"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ArtStudioProceduralCanvasView: View {
    @EnvironmentObject private var appSettings: AppSettings
    let kind: ArtStudioProceduralKind
    let drawingIndex: Int

    @State private var canvas = PKCanvasView()
    @State private var selectedColor: UIColor = .systemBlue
    @State private var width: CGFloat = 8
    @State private var erasing = false
    @State private var guideOpacity = 0.34

    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }
    private var pageIndex: Int { kind == .detailed ? drawingIndex : drawingIndex + 100 }
    private var title: ArtStudioDrawingTitle {
        kind == .detailed ? ArtStudioProceduralCatalog.detailedTitles[drawingIndex] : ArtStudioProceduralCatalog.simpleTitles[drawingIndex]
    }

    private let colors: [UIColor] = [.black, .white, .systemRed, .systemOrange, .systemYellow, .systemGreen, .systemTeal, .systemBlue, .systemPurple, .systemPink, .brown]

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.white
                ArtStudioProceduralPageView(index: pageIndex)
                    .opacity(guideOpacity)
                    .padding(14)
                    .allowsHitTesting(false)
                ProceduralPKCanvas(canvas: $canvas)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(.black.opacity(0.18)))
            .padding(10)

            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Button { erasing = false; applyTool() } label: {
                        Label(isGreek ? "Ζωγράφισε" : "Draw", systemImage: "pencil.tip")
                    }
                    .buttonStyle(.borderedProminent)

                    Button { erasing = true; applyTool() } label: {
                        Label(isGreek ? "Γόμα" : "Eraser", systemImage: "eraser.fill")
                    }
                    .buttonStyle(.bordered)

                    Button { canvas.undoManager?.undo() } label: { Image(systemName: "arrow.uturn.backward") }
                    Button { canvas.undoManager?.redo() } label: { Image(systemName: "arrow.uturn.forward") }
                    Button { canvas.drawing = PKDrawing() } label: { Image(systemName: "trash") }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                            Button {
                                selectedColor = color
                                erasing = false
                                applyTool()
                            } label: {
                                Circle()
                                    .fill(Color(uiColor: color))
                                    .frame(width: 34, height: 34)
                                    .overlay(Circle().stroke(color == .white ? Color.gray : Color.black.opacity(0.25), lineWidth: 1.5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                }

                HStack {
                    Image(systemName: "circle.fill").font(.system(size: 7))
                    Slider(value: $width, in: 2...28, step: 1).onChange(of: width) { _, _ in applyTool() }
                    Image(systemName: "circle.fill").font(.system(size: 18))
                }
                .padding(.horizontal, 14)

                HStack {
                    Image(systemName: "sun.min")
                    Slider(value: $guideOpacity, in: 0.08...0.65)
                    Image(systemName: "sun.max.fill")
                }
                .padding(.horizontal, 14)
            }
            .padding(.vertical, 10)
            .background(Color(red: 0.88, green: 0.88, blue: 0.88))
        }
        .background(Color(red: 0.95, green: 0.93, blue: 0.89).ignoresSafeArea())
        .preferredColorScheme(.light)
        .navigationTitle(isGreek ? title.gr : title.en)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            canvas.backgroundColor = .clear
            canvas.isOpaque = false
            canvas.drawingPolicy = .anyInput
            canvas.overrideUserInterfaceStyle = .light
            applyTool()
        }
    }

    private func applyTool() {
        if erasing {
            canvas.tool = PKEraserTool(.bitmap)
        } else {
            canvas.tool = PKInkingTool(.marker, color: selectedColor, width: width)
        }
    }
}

private struct ProceduralPKCanvas: UIViewRepresentable {
    @Binding var canvas: PKCanvasView
    func makeUIView(context: Context) -> PKCanvasView { canvas }
    func updateUIView(_ uiView: PKCanvasView, context: Context) { uiView.overrideUserInterfaceStyle = .light }
}
