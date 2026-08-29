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
                        Text("🎨").font(.system(size: 54))
                        Text(isGreek ? "Εργαστήριο Ζωγραφικής" : "Art Studio")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text(isGreek ? "Ζωγράφισε, χρωμάτισε και δημιούργησε!" : "Draw, color and create!")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.86))
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        modeCard(.freeDraw, "✏️", "Ελεύθερη Ζωγραφική", "Free Draw", "Λευκός καμβάς", "Blank canvas")
                        modeCard(.trace, "🪄", "Ζωγράφισε με Οδηγό", "Trace & Draw", "Αχνό σχέδιο για εξάσκηση", "Follow a faint guide")
                        modeCard(.coloring, "🖍️", "Χρωμάτισε", "Coloring Book", "90 θέματα ζωγραφικής", "90 drawing themes")
                        modeCard(.challenge, "🎯", "Πρόκληση", "Drawing Challenge", "Τι θα ζωγραφίσουμε;", "What shall we draw?")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Label(isGreek ? "Το δικό σου μικρό ατελιέ" : "Your little art studio", systemImage: "sparkles")
                            .font(.headline.weight(.black))
                        Text(isGreek ? "Μολύβι, πένα, μαρκαδόρος, πινέλο, γόμα, πολλά χρώματα, διαφορετικά πάχη, αναίρεση/επανάληψη και αποθήκευση έργων." : "Pencil, pen, marker, brush, eraser, lots of colors, different widths, undo/redo and saved artwork.")
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
        _ emoji: String,
        _ titleGR: String,
        _ titleEN: String,
        _ subtitleGR: String,
        _ subtitleEN: String
    ) -> some View {
        Button { selectedMode = mode } label: {
            VStack(spacing: 9) {
                Text(emoji).font(.system(size: 42))
                Text(isGreek ? titleGR : titleEN)
                    .font(.headline.weight(.black))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text(isGreek ? subtitleGR : subtitleEN)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.78))
            }
            .multilineTextAlignment(.center)
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
        case .brush: return "paintbrush.pointed.fill"
        case .eraser: return "eraser.fill"
        }
    }
}

private struct ArtColor: Identifiable {
    let id: String
    let swiftUIColor: Color
    let uiColor: UIColor

    static let palette: [ArtColor] = [
        .init(id: "black", swiftUIColor: .black, uiColor: .black),
        .init(id: "gray", swiftUIColor: .gray, uiColor: .gray),
        .init(id: "white", swiftUIColor: .white, uiColor: .white),
        .init(id: "red", swiftUIColor: .red, uiColor: .systemRed),
        .init(id: "orange", swiftUIColor: .orange, uiColor: .systemOrange),
        .init(id: "yellow", swiftUIColor: .yellow, uiColor: .systemYellow),
        .init(id: "green", swiftUIColor: .green, uiColor: .systemGreen),
        .init(id: "mint", swiftUIColor: .mint, uiColor: .systemMint),
        .init(id: "cyan", swiftUIColor: .cyan, uiColor: .systemCyan),
        .init(id: "blue", swiftUIColor: .blue, uiColor: .systemBlue),
        .init(id: "indigo", swiftUIColor: .indigo, uiColor: .systemIndigo),
        .init(id: "purple", swiftUIColor: .purple, uiColor: .systemPurple),
        .init(id: "pink", swiftUIColor: .pink, uiColor: .systemPink),
        .init(id: "brown", swiftUIColor: .brown, uiColor: .systemBrown)
    ]
}

private struct ArtTemplate: Identifiable, Hashable {
    let id: Int
    let greek: String
    let english: String
    let symbol: String
    let premium: Bool
}

private struct ArtStudioCanvasScreen: View {
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss

    let mode: ArtStudioMode

    @State private var canvasView = PKCanvasView()
    @State private var selectedTool: ArtTool = .pencil
    @State private var selectedColorID = "blue"
    @State private var lineWidth: CGFloat = 8
    @State private var guideOpacity: Double = 0.20
    @State private var selectedTemplate: ArtTemplate?
    @State private var showTemplatePicker = false
    @State private var challengeIndex = 0
    @State private var showSavedToast = false

    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }
    private var selectedColor: ArtColor {
        ArtColor.palette.first(where: { $0.id == selectedColorID }) ?? ArtColor.palette[9]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if mode == .challenge { challengeHeader }

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
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.18), lineWidth: 1))
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
                        Image(systemName: "xmark.circle.fill").font(.title2)
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { canvasView.undoManager?.undo() } label: { Image(systemName: "arrow.uturn.backward") }
                    Button { canvasView.undoManager?.redo() } label: { Image(systemName: "arrow.uturn.forward") }
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
                }
            }
            .sheet(isPresented: $showTemplatePicker) { templatePicker }
            .onAppear {
                configureCanvas()
                if mode == .trace || mode == .coloring { selectedTemplate = templates.first }
            }
            .onChange(of: selectedTool) { _, _ in updateTool() }
            .onChange(of: selectedColorID) { _, _ in updateTool() }
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
            Button { challengeIndex = (challengeIndex + 1) % challenges.count } label: {
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
                        Button { selectedTool = tool } label: {
                            VStack(spacing: 3) {
                                Image(systemName: tool.icon).font(.system(size: 21, weight: .bold))
                                Text(toolName(tool)).font(.caption2.weight(.black))
                            }
                            .foregroundStyle(selectedTool == tool ? Color.white : Color.black)
                            .frame(width: 70, height: 58)
                            .background(selectedTool == tool ? Color.blue : Color(red: 0.94, green: 0.94, blue: 0.94))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(selectedTool == tool ? 0 : 0.22), lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ArtColor.palette) { color in
                        Button {
                            selectedColorID = color.id
                            if selectedTool == .eraser { selectedTool = .pencil }
                        } label: {
                            Circle()
                                .fill(color.swiftUIColor)
                                .frame(width: 36, height: 36)
                                .overlay(Circle().stroke(color.id == "white" ? Color.black.opacity(0.35) : Color.black.opacity(0.12), lineWidth: 1))
                                .overlay(Circle().stroke(Color.black, lineWidth: selectedColorID == color.id ? 4 : 0))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
            }

            HStack(spacing: 12) {
                Image(systemName: "circle.fill").font(.system(size: 7)).foregroundStyle(.black)
                Slider(value: $lineWidth, in: 2...28, step: 1)
                Image(systemName: "circle.fill").font(.system(size: 19)).foregroundStyle(.black)

                if mode == .trace || mode == .coloring {
                    Button { showTemplatePicker = true } label: {
                        Label(isGreek ? "Σχέδιο" : "Picture", systemImage: "photo.on.rectangle")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.black)
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
                .foregroundStyle(.black)
                .padding(.horizontal, 14)
            }
        }
        .padding(.vertical, 10)
        .background(Color(red: 0.88, green: 0.88, blue: 0.88))
    }

    @ViewBuilder
    private func templateArtwork(_ template: ArtTemplate, thumbnail: Bool = false) -> some View {
        if template.id >= 80 {
            CapybaraLineArtView(
                sceneIndex: template.id - 80,
                lineOpacity: thumbnail ? 1 : (mode == .trace ? guideOpacity : 0.82)
            )
            .padding(thumbnail ? 4 : 14)
        } else {
            Image(systemName: template.symbol)
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(Color.black.opacity(thumbnail ? 1 : (mode == .trace ? guideOpacity : 0.72)))
                .padding(thumbnail ? 4 : 55)
        }
    }

    private func templateGuide(_ template: ArtTemplate) -> some View {
        VStack(spacing: 10) {
            templateArtwork(template)
            Text(isGreek ? template.greek : template.english)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.black.opacity(mode == .trace ? guideOpacity : 0.55))
        }
        .padding(10)
    }

    private var templatePicker: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(isGreek ? "🦫 Capybara & Φύση" : "🦫 Capybara & Nature")
                        .font(.title3.weight(.black))
                        .padding(.horizontal, 16)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 105), spacing: 12)], spacing: 12) {
                        ForEach(templates) { template in
                            Button {
                                selectedTemplate = template
                                showTemplatePicker = false
                            } label: {
                                VStack(spacing: 7) {
                                    ZStack(alignment: .topTrailing) {
                                        templateArtwork(template, thumbnail: true)
                                            .frame(height: 62)
                                        if template.premium {
                                            Image(systemName: "sparkles")
                                                .foregroundStyle(.orange)
                                                .font(.caption)
                                        }
                                    }
                                    Text(isGreek ? template.greek : template.english)
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.black)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(3)
                                }
                                .frame(maxWidth: .infinity, minHeight: 122)
                                .padding(10)
                                .background(template.id >= 80 ? Color.green.opacity(0.10) : Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 18).stroke(template.id >= 80 ? Color.green.opacity(0.45) : Color.black.opacity(0.12)))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
            }
            .background(Color(red: 0.95, green: 0.94, blue: 0.91))
            .navigationTitle(isGreek ? "90 Θέματα" : "90 Themes")
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

        let ink: PKInkingTool.InkType
        switch selectedTool {
        case .pencil: ink = .pencil
        case .pen: ink = .pen
        case .marker: ink = .marker
        case .brush: ink = .monoline
        case .eraser: ink = .pen
        }
        canvasView.tool = PKInkingTool(ink, color: selectedColor.uiColor, width: lineWidth)
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
        let basic: [(String, String, String)] = [
            ("Καρδιά", "Heart", "heart"), ("Αστέρι", "Star", "star"), ("Ήλιος", "Sun", "sun.max"), ("Φεγγάρι", "Moon", "moon"), ("Σύννεφο", "Cloud", "cloud"),
            ("Ουράνιο τόξο", "Rainbow", "rainbow"), ("Λουλούδι", "Flower", "camera.macro"), ("Φύλλο", "Leaf", "leaf"), ("Δέντρο", "Tree", "tree"), ("Βουνό", "Mountain", "mountain.2"),
            ("Ψάρι", "Fish", "fish"), ("Χελώνα", "Turtle", "tortoise"), ("Λαγουδάκι", "Bunny", "hare"), ("Γάτα", "Cat", "cat"), ("Σκύλος", "Dog", "dog"),
            ("Πουλάκι", "Bird", "bird"), ("Πεταλούδα", "Butterfly", "butterfly"), ("Μυρμήγκι", "Ant", "ant"), ("Πασχαλίτσα", "Ladybug", "ladybug"), ("Μέλισσα", "Bee", "allergens"),
            ("Καραβάκι", "Boat", "sailboat"), ("Αυτοκίνητο", "Car", "car"), ("Λεωφορείο", "Bus", "bus"), ("Τρένο", "Train", "tram"), ("Αεροπλάνο", "Airplane", "airplane"),
            ("Πύραυλος", "Rocket", "rocket"), ("Ποδήλατο", "Bicycle", "bicycle"), ("Σπίτι", "House", "house"), ("Κάστρο", "Castle", "building.columns"), ("Σκηνή", "Tent", "tent"),
            ("Δώρο", "Gift", "gift"), ("Μπαλόνι", "Balloon", "balloon"), ("Κορώνα", "Crown", "crown"), ("Μαγικό ραβδί", "Magic Wand", "wand.and.stars"), ("Διαμάντι", "Diamond", "diamond"),
            ("Μήλο", "Apple", "apple.logo"), ("Καρότο", "Carrot", "carrot"), ("Τούρτα", "Cake", "birthday.cake"), ("Μπάλα", "Ball", "soccerball"), ("Παζλ", "Puzzle", "puzzlepiece"),
            ("Μουσική", "Music", "music.note"), ("Βιβλίο", "Book", "book.closed"), ("Μολύβι", "Pencil", "pencil"), ("Χαμόγελο", "Smile", "face.smiling"), ("Πατουσάκι", "Paw", "pawprint"),
            ("Νιφάδα", "Snowflake", "snowflake"), ("Ομπρέλα", "Umbrella", "umbrella"), ("Μαγικό αστέρι", "Magic Star", "sparkles"), ("Βάρκα στο ηλιοβασίλεμα", "Sunset Boat", "sailboat.fill"), ("Δάσος", "Forest", "tree.fill")
        ]

        let fantasy: [(String, String, String)] = [
            ("Πριγκίπισσα μπροστά σε μαγικό κάστρο", "Princess at a magical castle", "crown.fill"),
            ("Πριγκίπισσα και μονόκερος στον κήπο", "Princess and unicorn garden", "crown"),
            ("Κάστρο πάνω από τα σύννεφα", "Castle above the clouds", "cloud.sun.fill"),
            ("Παραμυθένιο κάστρο με γέφυρα και ποτάμι", "Fairytale castle with bridge and river", "building.columns.fill"),
            ("Κάστρο μέσα σε μαγεμένο δάσος", "Castle in an enchanted forest", "tree.fill"),
            ("Μονόκερος κάτω από ουράνιο τόξο", "Unicorn under a rainbow", "rainbow"),
            ("Μονόκερος δίπλα σε καταρράκτη", "Unicorn by a waterfall", "water.waves"),
            ("Οικογένεια μονόκερων σε λουλουδένιο λιβάδι", "Unicorn family in a flower meadow", "camera.macro"),
            ("Φοίνικας πουλί με ανοιχτά φτερά", "Phoenix with open wings", "bird.fill"),
            ("Φοίνικας που πετά πάνω από ηφαίστειο", "Phoenix flying over a volcano", "flame.fill"),
            ("Δράκος που φυλάει κρυστάλλινο κάστρο", "Dragon guarding a crystal castle", "shield.lefthalf.filled"),
            ("Φιλικός δράκος και πριγκίπισσα", "Friendly dragon and princess", "heart.fill"),
            ("Γοργόνα σε υποθαλάσσιο παλάτι", "Mermaid in an underwater palace", "water.waves"),
            ("Γοργόνα με δελφίνια και κοράλλια", "Mermaid with dolphins and coral", "fish.fill"),
            ("Βυθισμένο κάστρο με θησαυρό", "Sunken castle and treasure", "diamond.fill"),
            ("Νεράιδα σε κήπο με τεράστια λουλούδια", "Fairy in a giant flower garden", "wand.and.stars"),
            ("Νεράιδες γύρω από μαγικό δέντρο", "Fairies around a magical tree", "sparkles"),
            ("Μαγικό χωριό μέσα σε μανιτάρια", "Magical mushroom village", "house.fill"),
            ("Τοπίο με καταρράκτη, βουνά και ελάφια", "Waterfall, mountains and deer", "mountain.2.fill"),
            ("Λίμνη με κύκνους και παλάτι", "Swan lake and palace", "water.waves"),
            ("Χιονισμένο κάστρο στα βουνά", "Snow castle in the mountains", "snowflake"),
            ("Μαγικό χειμωνιάτικο χωριό", "Magical winter village", "snowflake.circle.fill"),
            ("Πειρατικό καράβι σε νησί θησαυρού", "Pirate ship at treasure island", "sailboat.fill"),
            ("Πειρατές μπροστά σε κρυμμένο σεντούκι", "Pirates and hidden treasure chest", "shippingbox.fill"),
            ("Ιππότης μπροστά σε κάστρο και δράκο", "Knight, castle and dragon", "shield.fill"),
            ("Διαστημικό κάστρο σε μακρινό πλανήτη", "Space castle on a distant planet", "globe.americas.fill"),
            ("Μαγική πόλη κάτω από τα αστέρια", "Magical city under the stars", "sparkles"),
            ("Ζούγκλα με αρχαίο ναό και ζώα", "Jungle temple and animals", "leaf.fill"),
            ("Παραμυθένιο δάσος με ποτάμι και ζωάκια", "Fairytale forest river and animals", "tree.circle.fill"),
            ("Μεγάλο δέντρο-σπίτι με νεράιδες και γέφυρες", "Giant fairy treehouse with bridges", "tree.fill")
        ]

        let capybara: [(String, String, String)] = [
            ("Capybara στο δάσος", "Capybara in the forest", "leaf.fill"),
            ("Capybara δίπλα στο ποτάμι", "Capybara by the river", "water.waves"),
            ("Οικογένεια capybara με μικρά", "Capybara family with babies", "heart.fill"),
            ("Capybara με πεταλούδες και λουλούδια", "Capybara with butterflies and flowers", "butterfly.fill"),
            ("Capybara κάτω από μεγάλο δέντρο", "Capybara under a giant tree", "tree.fill"),
            ("Capybara δίπλα σε καταρράκτη", "Capybara by a waterfall", "water.waves"),
            ("Capybara με πουλάκια", "Capybara with little birds", "bird.fill"),
            ("Capybara σε μαγικό δάσος", "Capybara in an enchanted forest", "sparkles"),
            ("Capybara σε λίμνη με νούφαρα", "Capybara in a lily pond", "camera.macro"),
            ("Capybara σε θερμές πηγές", "Capybara in hot springs", "drop.fill")
        ]

        let basicTemplates = basic.enumerated().map {
            ArtTemplate(id: $0.offset, greek: $0.element.0, english: $0.element.1, symbol: $0.element.2, premium: false)
        }
        let fantasyTemplates = fantasy.enumerated().map {
            ArtTemplate(id: 50 + $0.offset, greek: $0.element.0, english: $0.element.1, symbol: $0.element.2, premium: true)
        }
        let capybaraTemplates = capybara.enumerated().map {
            ArtTemplate(id: 80 + $0.offset, greek: $0.element.0, english: $0.element.1, symbol: $0.element.2, premium: true)
        }
        return basicTemplates + fantasyTemplates + capybaraTemplates
    }

    private var challenges: [(String, String)] {
        [
            ("μια γοργόνα κάτω από τη θάλασσα 🧜‍♀️", "a mermaid under the sea 🧜‍♀️"),
            ("έναν χαρούμενο δεινόσαυρο 🦖", "a happy dinosaur 🦖"),
            ("ένα κάστρο στα σύννεφα 🏰", "a castle in the clouds 🏰"),
            ("ένα διαστημόπλοιο που πάει στο φεγγάρι 🚀", "a spaceship flying to the moon 🚀"),
            ("ένα μαγικό δάσος ✨", "a magical forest ✨"),
            ("έναν μονόκερο με ουράνιο τόξο 🦄", "a unicorn with a rainbow 🦄"),
            ("έναν φοίνικα που πετά μέσα από φωτιές 🔥", "a phoenix flying through fire 🔥"),
            ("μια πριγκίπισσα με το δικό της κάστρο 👑", "a princess with her own castle 👑"),
            ("ένα τοπίο με καταρράκτη και βουνά 🏔️", "a waterfall and mountain landscape 🏔️"),
            ("έναν δράκο που φυλάει έναν θησαυρό 🐉", "a dragon guarding treasure 🐉"),
            ("ένα capybara που εξερευνά το δάσος 🦫🌲", "a capybara exploring the forest 🦫🌲"),
            ("μια οικογένεια capybara δίπλα στο ποτάμι 🦫💧", "a capybara family by the river 🦫💧"),
            ("ένα capybara σε μαγικό δάσος με φωτάκια ✨", "a capybara in a glowing magical forest ✨"),
            ("ένα capybara με πεταλούδες και τεράστια λουλούδια 🦋", "a capybara with butterflies and giant flowers 🦋")
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
