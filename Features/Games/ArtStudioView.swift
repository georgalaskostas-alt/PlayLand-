import SwiftUI
import PencilKit

struct ArtStudioView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @State private var selectedMode: ArtStudioMode?

    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.22, green: 0.09, blue: 0.42), Color(red: 0.12, green: 0.39, blue: 0.62)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    VStack(spacing: 7) {
                        Text("🎨")
                            .font(.system(size: 54))
                        Text(isGreek ? "Εργαστήριο Ζωγραφικής" : "Art Studio")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        Text(isGreek ? "Ζωγράφισε, χρωμάτισε και δημιούργησε!" : "Draw, color and create!")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.86))
                    }
                    .padding(.top, 10)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        modeCard(.freeDraw, emoji: "✏️", titleGR: "Ελεύθερη Ζωγραφική", titleEN: "Free Draw", subtitleGR: "Λευκός καμβάς", subtitleEN: "Blank canvas")
                        modeCard(.trace, emoji: "🪄", titleGR: "Ζωγράφισε με Οδηγό", titleEN: "Trace & Draw", subtitleGR: "Αχνό σχέδιο για εξάσκηση", subtitleEN: "Follow a faint guide")
                        modeCard(.coloring, emoji: "🖍️", titleGR: "Χρωμάτισε", titleEN: "Coloring Book", subtitleGR: "50 έτοιμα σχέδια", subtitleEN: "50 ready pictures")
                        modeCard(.challenge, emoji: "🎯", titleGR: "Πρόκληση", titleEN: "Drawing Challenge", subtitleGR: "Τι θα ζωγραφίσουμε;", subtitleEN: "What shall we draw?")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Label(isGreek ? "Το δικό σου μικρό ατελιέ" : "Your little art studio", systemImage: "sparkles")
                            .font(.headline.weight(.black))
                        Text(isGreek ? "Μολύβι, πινέλο, μαρκαδόρος, γόμα, πολλά χρώματα, διαφορετικά πάχη, αναίρεση/επανάληψη και αποθήκευση έργων." : "Pencil, brush, marker, eraser, lots of colors, different widths, undo/redo and saved artwork.")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.black.opacity(0.26))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                .padding(18)
                .padding(.bottom, 90)
            }
        }
        .navigationTitle(isGreek ? "Ζωγραφική" : "Art Studio")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $selectedMode) { mode in
            ArtStudioCanvasScreen(mode: mode)
                .environmentObject(appSettings)
        }
    }

    private func modeCard(
        _ mode: ArtStudioMode,
        emoji: String,
        titleGR: String,
        titleEN: String,
        subtitleGR: String,
        subtitleEN: String
    ) -> some View {
        Button { selectedMode = mode } label: {
            VStack(spacing: 9) {
                Text(emoji).font(.system(size: 42))
                Text(isGreek ? titleGR : titleEN)
                    .font(.headline.weight(.black))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text(isGreek ? subtitleGR : subtitleEN)
                    .font(.caption.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.78))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 152)
            .padding(12)
            .background(.white.opacity(0.14))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.18), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(.plain)
    }
}

enum ArtStudioMode: String, Identifiable {
    case freeDraw, trace, coloring, challenge
    var id: String { rawValue }
}

private enum ArtTool: String, CaseIterable, Identifiable {
    case pencil, pen, marker, brush, eraser
    var id: String { rawValue }

    var icon: String {
        switch self {
        case .pencil: return "pencil"
        case .pen: return "pencil.tip"
        case .marker: return "highlighter"
        case .brush: return "paintbrush.pointed"
        case .eraser: return "eraser.fill"
        }
    }
}

private struct ArtTemplate: Identifiable, Hashable {
    let id: Int
    let greek: String
    let english: String
    let symbol: String
}

private struct ArtStudioCanvasScreen: View {
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss

    let mode: ArtStudioMode

    @State private var canvasView = PKCanvasView()
    @State private var selectedTool: ArtTool = .pencil
    @State private var selectedColor: Color = .blue
    @State private var lineWidth: CGFloat = 8
    @State private var guideOpacity: Double = 0.20
    @State private var selectedTemplate: ArtTemplate?
    @State private var showTemplatePicker = false
    @State private var challengeIndex = 0
    @State private var showSavedToast = false

    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }

    private let palette: [Color] = [
        .black, .gray, .white, .red, .orange, .yellow, .green, .mint,
        .cyan, .blue, .indigo, .purple, .pink, .brown
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if mode == .challenge {
                    challengeHeader
                }

                ZStack {
                    Color.white

                    if (mode == .trace || mode == .coloring), let template = selectedTemplate {
                        templateGuide(template)
                            .allowsHitTesting(false)
                    }

                    PencilCanvasRepresentable(canvasView: $canvasView)
                        .background(Color.clear)
                }
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.12), lineWidth: 1))
                .padding(.horizontal, 10)
                .padding(.top, 8)

                toolControls
            }
            .background(Color(red: 0.96, green: 0.94, blue: 0.90).ignoresSafeArea())
            .navigationTitle(screenTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { canvasView.undoManager?.undo() } label: { Image(systemName: "arrow.uturn.backward") }
                        .disabled(!(canvasView.undoManager?.canUndo ?? false))
                    Button { canvasView.undoManager?.redo() } label: { Image(systemName: "arrow.uturn.forward") }
                        .disabled(!(canvasView.undoManager?.canRedo ?? false))
                    Button { clearCanvas() } label: { Image(systemName: "trash") }
                    Button { saveArtwork() } label: { Image(systemName: "square.and.arrow.down") }
                }
            }
            .overlay(alignment: .top) {
                if showSavedToast {
                    Text(isGreek ? "✨ Η ζωγραφιά αποθηκεύτηκε!" : "✨ Artwork saved!")
                        .font(.headline.weight(.bold))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(.black.opacity(0.78))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .sheet(isPresented: $showTemplatePicker) {
                templatePicker
            }
            .onAppear {
                configureCanvas()
                if mode == .trace || mode == .coloring {
                    selectedTemplate = templates.first
                }
            }
            .onChange(of: selectedTool) { _, _ in updateTool() }
            .onChange(of: selectedColor) { _, _ in updateTool() }
            .onChange(of: lineWidth) { _, _ in updateTool() }
        }
    }

    private var screenTitle: String {
        switch mode {
        case .freeDraw: return isGreek ? "Ελεύθερη Ζωγραφική" : "Free Draw"
        case .trace: return isGreek ? "Ζωγράφισε με Οδηγό" : "Trace & Draw"
        case .coloring: return isGreek ? "Χρωμάτισε" : "Coloring Book"
        case .challenge: return isGreek ? "Πρόκληση Ζωγραφικής" : "Drawing Challenge"
        }
    }

    private var challengeHeader: some View {
        VStack(spacing: 8) {
            Text(isGreek ? "Ζωγράφισέ μου…" : "Draw me…")
                .font(.caption.weight(.black))
                .foregroundStyle(.secondary)
            Text(isGreek ? challenges[challengeIndex].0 : challenges[challengeIndex].1)
                .font(.title2.weight(.black))
                .multilineTextAlignment(.center)
            Button {
                challengeIndex = (challengeIndex + 1) % challenges.count
            } label: {
                Label(isGreek ? "Άλλη πρόκληση" : "New challenge", systemImage: "dice.fill")
                    .font(.subheadline.weight(.bold))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(Color.yellow.opacity(0.22))
    }

    private var toolControls: some View {
        VStack(spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 9) {
                    ForEach(ArtTool.allCases) { tool in
                        Button {
                            selectedTool = tool
                        } label: {
                            VStack(spacing: 3) {
                                Image(systemName: tool.icon).font(.system(size: 20, weight: .bold))
                                Text(toolName(tool)).font(.caption2.weight(.bold))
                            }
                            .foregroundStyle(selectedTool == tool ? .white : .primary)
                            .frame(width: 67, height: 55)
                            .background(selectedTool == tool ? Color.blue : Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(palette.enumerated()), id: \.offset) { _, color in
                        Button {
                            selectedColor = color
                            if selectedTool == .eraser { selectedTool = .pencil }
                        } label: {
                            Circle()
                                .fill(color)
                                .frame(width: 34, height: 34)
                                .overlay(Circle().stroke(Color.primary.opacity(selectedColor == color ? 0.9 : 0.2), lineWidth: selectedColor == color ? 4 : 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
            }

            HStack(spacing: 12) {
                Image(systemName: "circle.fill").font(.system(size: 7))
                Slider(value: $lineWidth, in: 2...28, step: 1)
                Image(systemName: "circle.fill").font(.system(size: 19))

                if mode == .trace || mode == .coloring {
                    Button { showTemplatePicker = true } label: {
                        Label(isGreek ? "Σχέδιο" : "Picture", systemImage: "photo.on.rectangle")
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)

            if mode == .trace {
                HStack {
                    Image(systemName: "sun.min")
                    Slider(value: $guideOpacity, in: 0.08...0.45)
                    Image(systemName: "sun.max.fill")
                }
                .padding(.horizontal, 14)
            }
        }
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private func templateGuide(_ template: ArtTemplate) -> some View {
        VStack(spacing: 18) {
            Image(systemName: template.symbol)
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(Color.black.opacity(mode == .trace ? guideOpacity : 0.72))
                .padding(55)
            Text(isGreek ? template.greek : template.english)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.black.opacity(mode == .trace ? guideOpacity : 0.55))
        }
        .padding(12)
    }

    private var templatePicker: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 105), spacing: 12)], spacing: 12) {
                    ForEach(templates) { template in
                        Button {
                            selectedTemplate = template
                            showTemplatePicker = false
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: template.symbol)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 58)
                                    .foregroundStyle(.primary)
                                Text(isGreek ? template.greek : template.english)
                                    .font(.caption.weight(.bold))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity, minHeight: 105)
                            .padding(10)
                            .background(Color.secondary.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .navigationTitle(isGreek ? "50 Σχέδια" : "50 Pictures")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isGreek ? "Κλείσιμο" : "Done") { showTemplatePicker = false }
                }
            }
        }
    }

    private func toolName(_ tool: ArtTool) -> String {
        if isGreek {
            switch tool {
            case .pencil: return "Μολύβι"
            case .pen: return "Πένα"
            case .marker: return "Μαρκαδ."
            case .brush: return "Πινέλο"
            case .eraser: return "Γόμα"
            }
        }
        return tool.rawValue.capitalized
    }

    private func configureCanvas() {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        canvasView.alwaysBounceVertical = false
        canvasView.alwaysBounceHorizontal = false
        updateTool()
    }

    private func updateTool() {
        if selectedTool == .eraser {
            canvasView.tool = PKEraserTool(.vector)
            return
        }

        let inkType: PKInkingTool.InkType
        switch selectedTool {
        case .pencil: inkType = .pencil
        case .pen: inkType = .pen
        case .marker: inkType = .marker
        case .brush: inkType = .monoline
        case .eraser: inkType = .pen
        }

        canvasView.tool = PKInkingTool(inkType, color: UIColor(selectedColor), width: lineWidth)
    }

    private func clearCanvas() {
        canvasView.drawing = PKDrawing()
    }

    private func saveArtwork() {
        let bounds = canvasView.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }
        let image = canvasView.drawing.image(from: bounds, scale: UIScreen.main.scale)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        withAnimation { showSavedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            withAnimation { showSavedToast = false }
        }
    }

    private var templates: [ArtTemplate] {
        let data: [(String, String, String)] = [
            ("Καρδιά", "Heart", "heart"), ("Αστέρι", "Star", "star"), ("Ήλιος", "Sun", "sun.max"), ("Φεγγάρι", "Moon", "moon"), ("Σύννεφο", "Cloud", "cloud"),
            ("Ουράνιο τόξο", "Rainbow", "rainbow"), ("Λουλούδι", "Flower", "camera.macro"), ("Φύλλο", "Leaf", "leaf"), ("Δέντρο", "Tree", "tree"), ("Βουνό", "Mountain", "mountain.2"),
            ("Ψάρι", "Fish", "fish"), ("Χελώνα", "Turtle", "tortoise"), ("Λαγουδάκι", "Bunny", "hare"), ("Γάτα", "Cat", "cat"), ("Σκύλος", "Dog", "dog"),
            ("Πουλάκι", "Bird", "bird"), ("Πεταλούδα", "Butterfly", "butterfly"), ("Μυρμήγκι", "Ant", "ant"), ("Πασχαλίτσα", "Ladybug", "ladybug"), ("Μέλισσα", "Bee", "allergens"),
            ("Καραβάκι", "Boat", "sailboat"), ("Αυτοκίνητο", "Car", "car"), ("Λεωφορείο", "Bus", "bus"), ("Τρένο", "Train", "tram"), ("Αεροπλάνο", "Airplane", "airplane"),
            ("Πύραυλος", "Rocket", "rocket"), ("Ποδήλατο", "Bicycle", "bicycle"), ("Σπίτι", "House", "house"), ("Κάστρο", "Castle", "building.columns"), ("Σκηνή", "Tent", "tent"),
            ("Δώρο", "Gift", "gift"), ("Μπαλόνι", "Balloon", "balloon"), ("Κορώνα", "Crown", "crown"), ("Μαγικό ραβδί", "Magic Wand", "wand.and.stars"), ("Διαμάντι", "Diamond", "diamond"),
            ("Μήλο", "Apple", "apple.logo"), ("Κεράσια", "Cherries", "circle.grid.2x2"), ("Καρότο", "Carrot", "carrot"), ("Τούρτα", "Cake", "birthday.cake"), ("Παγωτό", "Ice Cream", "takeoutbag.and.cup.and.straw"),
            ("Μπάλα", "Ball", "soccerball"), ("Παζλ", "Puzzle", "puzzlepiece"), ("Μουσική", "Music", "music.note"), ("Βιβλίο", "Book", "book.closed"), ("Μολύβι", "Pencil", "pencil"),
            ("Χαμόγελο", "Smile", "face.smiling"), ("Πατουσάκι", "Paw", "pawprint"), ("Νιφάδα", "Snowflake", "snowflake"), ("Ομπρέλα", "Umbrella", "umbrella"), ("Μαγικό αστέρι", "Magic Star", "sparkles")
        ]
        return data.enumerated().map { index, row in
            ArtTemplate(id: index, greek: row.0, english: row.1, symbol: row.2)
        }
    }

    private var challenges: [(String, String)] {
        [
            ("μια γοργόνα κάτω από τη θάλασσα 🧜‍♀️", "a mermaid under the sea 🧜‍♀️"),
            ("έναν χαρούμενο δεινόσαυρο 🦖", "a happy dinosaur 🦖"),
            ("ένα κάστρο στα σύννεφα 🏰", "a castle in the clouds 🏰"),
            ("ένα διαστημόπλοιο που πάει στο φεγγάρι 🚀", "a spaceship flying to the moon 🚀"),
            ("ένα μαγικό δάσος ✨", "a magical forest ✨"),
            ("ένα πολύχρωμο ψάρι 🐠", "a colorful fish 🐠"),
            ("ένα αστείο τερατάκι 👾", "a funny little monster 👾"),
            ("το σπίτι των ονείρων σου 🏡", "your dream house 🏡"),
            ("έναν μονόκερο με ουράνιο τόξο 🦄", "a unicorn with a rainbow 🦄"),
            ("ένα ρομπότ φίλο 🤖", "a friendly robot 🤖"),
            ("ένα πειρατικό καράβι 🏴‍☠️", "a pirate ship 🏴‍☠️"),
            ("ένα ζωάκι που δεν υπάρχει στη Γη 🌍", "an animal that does not exist on Earth 🌍"),
            ("μια πόλη στο διάστημα 🌌", "a city in space 🌌"),
            ("μια τεράστια τούρτα γενεθλίων 🎂", "a giant birthday cake 🎂"),
            ("τον πιο αστείο δράκο 🐉", "the funniest dragon 🐉")
        ]
    }
}

private struct PencilCanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

#Preview {
    NavigationStack {
        ArtStudioView()
            .environmentObject(AppSettings.shared)
    }
}
