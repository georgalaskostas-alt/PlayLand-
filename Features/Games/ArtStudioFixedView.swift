import SwiftUI
import PencilKit

struct ArtStudioFixedView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @State private var mode: Studio2Mode?
    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.purple.opacity(0.85), .blue.opacity(0.78)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    Text("🎨").font(.system(size: 52))
                    Text(isGreek ? "Εργαστήριο Ζωγραφικής" : "Art Studio")
                        .font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(.white)
                    Text(isGreek ? "Ζωγράφισε, χρωμάτισε και δημιούργησε!" : "Draw, color and create!")
                        .font(.headline.weight(.bold)).foregroundStyle(.white.opacity(0.9))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        card(.free, "✏️", isGreek ? "Ελεύθερη Ζωγραφική" : "Free Draw")
                        card(.trace, "🪄", isGreek ? "Ζωγράφισε με Οδηγό" : "Trace & Draw")
                        card(.color, "🖍️", isGreek ? "Χρωμάτισε" : "Coloring Book")
                        card(.challenge, "🎯", isGreek ? "Πρόκληση" : "Challenge")
                    }
                }
                .padding(18)
            }
        }
        .fullScreenCover(item: $mode) { mode in
            Studio2Canvas(mode: mode).environmentObject(appSettings)
        }
    }

    private func card(_ mode: Studio2Mode, _ emoji: String, _ title: String) -> some View {
        Button { self.mode = mode } label: {
            VStack(spacing: 10) {
                Text(emoji).font(.system(size: 42))
                Text(title).font(.headline.weight(.black)).multilineTextAlignment(.center)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 138)
            .padding(12)
            .background(.white.opacity(0.15))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.24)))
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }.buttonStyle(.plain)
    }
}

enum Studio2Mode: String, Identifiable { case free, trace, color, challenge; var id: String { rawValue } }
private enum Studio2Tool: String, CaseIterable, Identifiable { case pencil, pen, marker, brush, eraser; var id: String { rawValue } }
private struct Studio2Page: Identifiable { let id: Int; let gr: String; let en: String; let kind: Studio2PageKind; let variant: Int }
private enum Studio2PageKind { case capybara, castle, princess, unicorn, mermaid, dragon, phoenix, fairy, landscape, pirate }

private struct Studio2Canvas: View {
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss
    let mode: Studio2Mode

    @State private var canvas = PKCanvasView()
    @State private var tool: Studio2Tool = .pencil
    @State private var colorID = "black"
    @State private var width: CGFloat = 7
    @State private var selectedPage = 0
    @State private var showPages = false
    @State private var guideOpacity = 0.24
    @State private var challenge = 0

    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }
    private let colors: [(String, Color, UIColor)] = [
        ("black", .black, UIColor(red: 0, green: 0, blue: 0, alpha: 1)),
        ("gray", .gray, .darkGray), ("white", .white, .white), ("red", .red, .systemRed),
        ("orange", .orange, .systemOrange), ("yellow", .yellow, .systemYellow), ("green", .green, .systemGreen),
        ("mint", .mint, .systemMint), ("cyan", .cyan, .systemCyan), ("blue", .blue, .systemBlue),
        ("purple", .purple, .systemPurple), ("pink", .pink, .systemPink), ("brown", .brown, .systemBrown)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if mode == .challenge { challengeHeader }
                ZStack {
                    Color.white
                    if mode == .trace || mode == .color {
                        pageArtwork(pages[selectedPage])
                            .opacity(mode == .trace ? guideOpacity : 1)
                            .padding(18)
                            .allowsHitTesting(false)
                    }
                    Studio2PKCanvas(canvas: $canvas)
                }
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(.black.opacity(0.18)))
                .padding(10)
                controls
            }
            .background(Color(red: 0.95, green: 0.93, blue: 0.89).ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button { dismiss() } label: { Image(systemName: "xmark.circle.fill").font(.title2) } }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { canvas.undoManager?.undo() } label: { Image(systemName: "arrow.uturn.backward") }
                    Button { canvas.undoManager?.redo() } label: { Image(systemName: "arrow.uturn.forward") }
                    Button { canvas.drawing = PKDrawing() } label: { Image(systemName: "trash") }
                }
            }
            .sheet(isPresented: $showPages) { pagePicker }
            .onAppear { configureCanvas() }
            .onChange(of: tool) { _, _ in updateTool() }
            .onChange(of: colorID) { _, _ in updateTool() }
            .onChange(of: width) { _, _ in updateTool() }
        }
    }

    private var title: String {
        switch mode {
        case .free: return isGreek ? "Ελεύθερη Ζωγραφική" : "Free Draw"
        case .trace: return isGreek ? "Ζωγράφισε με Οδηγό" : "Trace & Draw"
        case .color: return isGreek ? "Χρωμάτισε" : "Coloring Book"
        case .challenge: return isGreek ? "Πρόκληση Ζωγραφικής" : "Drawing Challenge"
        }
    }

    private var challengeHeader: some View {
        let promptsGR = ["Ζωγράφισε ένα κάστρο με πριγκίπισσα", "Ζωγράφισε ένα capybara στο δάσος", "Ζωγράφισε έναν μονόκερο δίπλα σε καταρράκτη", "Ζωγράφισε έναν φοίνικα που πετά", "Ζωγράφισε μια γοργόνα σε παλάτι"]
        let promptsEN = ["Draw a castle with a princess", "Draw a capybara in the forest", "Draw a unicorn by a waterfall", "Draw a flying phoenix", "Draw a mermaid in a palace"]
        return HStack {
            Text(isGreek ? promptsGR[challenge] : promptsEN[challenge]).font(.headline.weight(.black)).multilineTextAlignment(.center)
            Button { challenge = (challenge + 1) % promptsGR.count } label: { Image(systemName: "dice.fill") }
        }.padding(12).frame(maxWidth: .infinity).background(.yellow.opacity(0.25))
    }

    private var controls: some View {
        VStack(spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 9) {
                    ForEach(Studio2Tool.allCases) { item in
                        Button { tool = item } label: {
                            VStack(spacing: 3) {
                                Image(systemName: icon(item)).font(.system(size: 21, weight: .bold))
                                Text(name(item)).font(.caption2.weight(.black))
                            }
                            .foregroundStyle(tool == item ? .white : .black)
                            .frame(width: 72, height: 58)
                            .background(tool == item ? Color.blue : Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.black.opacity(0.2)))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }.buttonStyle(.plain)
                    }
                }.padding(.horizontal, 10)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(colors, id: \.0) { item in
                        Button {
                            colorID = item.0
                            if tool == .eraser { tool = .pencil }
                        } label: {
                            Circle().fill(item.1).frame(width: 36, height: 36)
                                .overlay(Circle().stroke(.black.opacity(item.0 == "white" ? 0.45 : 0.15), lineWidth: 1))
                                .overlay(Circle().stroke(.black, lineWidth: colorID == item.0 ? 4 : 0))
                        }.buttonStyle(.plain)
                    }
                }.padding(.horizontal, 12)
            }
            HStack {
                Image(systemName: "circle.fill").font(.system(size: 7))
                Slider(value: $width, in: 2...30, step: 1)
                Image(systemName: "circle.fill").font(.system(size: 19))
                if mode == .trace || mode == .color {
                    Button { showPages = true } label: { Label(isGreek ? "Σχέδιο" : "Picture", systemImage: "photo.on.rectangle") }.buttonStyle(.bordered)
                }
            }.padding(.horizontal, 14)
            if mode == .trace {
                HStack { Image(systemName: "sun.min"); Slider(value: $guideOpacity, in: 0.08...0.5); Image(systemName: "sun.max.fill") }.padding(.horizontal, 14)
            }
        }
        .padding(.vertical, 10)
        .foregroundStyle(.black)
        .background(Color(red: 0.88, green: 0.88, blue: 0.88))
    }

    private func configureCanvas() {
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.drawingPolicy = .anyInput
        canvas.minimumZoomScale = 1
        canvas.maximumZoomScale = 3
        updateTool()
    }

    private func updateTool() {
        if tool == .eraser {
            // Bitmap eraser removes only the pixels/stroke segment under the finger instead of deleting the full stroke.
            canvas.tool = PKEraserTool(.bitmap)
            return
        }
        let ink: PKInkingTool.InkType
        switch tool {
        case .pencil: ink = .pencil
        case .pen: ink = .pen
        case .marker: ink = .marker
        case .brush: ink = .monoline
        case .eraser: ink = .pen
        }
        let selected = colors.first(where: { $0.0 == colorID }) ?? colors[0]
        canvas.tool = PKInkingTool(ink, color: selected.2, width: width)
    }

    private func icon(_ tool: Studio2Tool) -> String {
        switch tool { case .pencil: return "pencil"; case .pen: return "pencil.tip"; case .marker: return "highlighter"; case .brush: return "paintbrush.pointed.fill"; case .eraser: return "eraser.fill" }
    }
    private func name(_ tool: Studio2Tool) -> String {
        if isGreek { switch tool { case .pencil: return "Μολύβι"; case .pen: return "Πένα"; case .marker: return "Μαρκαδ."; case .brush: return "Πινέλο"; case .eraser: return "Γόμα" } }
        return tool.rawValue.capitalized
    }

    private var pagePicker: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 12)], spacing: 12) {
                    ForEach(pages) { page in
                        Button {
                            selectedPage = page.id
                            showPages = false
                            canvas.drawing = PKDrawing()
                        } label: {
                            VStack(spacing: 7) {
                                pageArtwork(page).frame(height: 105).padding(5).background(.white).clipped()
                                Text(isGreek ? page.gr : page.en).font(.caption.weight(.bold)).foregroundStyle(.black).lineLimit(2).multilineTextAlignment(.center)
                            }
                            .padding(8).background(.white).clipShape(RoundedRectangle(cornerRadius: 16))
                        }.buttonStyle(.plain)
                    }
                }.padding(14)
            }
            .background(Color(red: 0.94, green: 0.92, blue: 0.88))
            .navigationTitle(isGreek ? "30 σχέδια" : "30 pictures")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button(isGreek ? "Κλείσιμο" : "Done") { showPages = false } } }
        }
    }

    @ViewBuilder
    private func pageArtwork(_ page: Studio2Page) -> some View {
        switch page.kind {
        case .capybara: CapybaraLineArtView(sceneIndex: page.variant, lineOpacity: 1)
        default: FantasyColoringLineArt(kind: page.kind, variant: page.variant)
        }
    }

    private var pages: [Studio2Page] {
        [
            .init(id:0,gr:"Capybara στο δάσος",en:"Capybara in the forest",kind:.capybara,variant:0),
            .init(id:1,gr:"Capybara δίπλα στο ποτάμι",en:"Capybara by the river",kind:.capybara,variant:1),
            .init(id:2,gr:"Οικογένεια capybara",en:"Capybara family",kind:.capybara,variant:2),
            .init(id:3,gr:"Capybara με πεταλούδες",en:"Capybara with butterflies",kind:.capybara,variant:3),
            .init(id:4,gr:"Capybara κάτω από το δέντρο",en:"Capybara under a tree",kind:.capybara,variant:4),
            .init(id:5,gr:"Capybara στον καταρράκτη",en:"Capybara by a waterfall",kind:.capybara,variant:5),
            .init(id:6,gr:"Κάστρο των ονείρων",en:"Dream castle",kind:.castle,variant:0),
            .init(id:7,gr:"Κάστρο με πύργους και κήπο",en:"Castle towers and garden",kind:.castle,variant:1),
            .init(id:8,gr:"Χειμωνιάτικο κάστρο",en:"Winter castle",kind:.castle,variant:2),
            .init(id:9,gr:"Παλάτι στη λίμνη",en:"Lake palace",kind:.castle,variant:3),
            .init(id:10,gr:"Πριγκίπισσα στο μπαλκόνι",en:"Princess on the balcony",kind:.princess,variant:0),
            .init(id:11,gr:"Πριγκίπισσα με καθρέφτη",en:"Princess with a mirror",kind:.princess,variant:1),
            .init(id:12,gr:"Πριγκίπισσα και γατάκι",en:"Princess and kitten",kind:.princess,variant:2),
            .init(id:13,gr:"Πριγκίπισσα και μονόκερος",en:"Princess and unicorn",kind:.princess,variant:3),
            .init(id:14,gr:"Μονόκερος στο λιβάδι",en:"Unicorn meadow",kind:.unicorn,variant:0),
            .init(id:15,gr:"Μονόκερος και καταρράκτης",en:"Unicorn waterfall",kind:.unicorn,variant:1),
            .init(id:16,gr:"Μονόκερος στα σύννεφα",en:"Unicorn in clouds",kind:.unicorn,variant:2),
            .init(id:17,gr:"Γοργόνα και παλάτι",en:"Mermaid and palace",kind:.mermaid,variant:0),
            .init(id:18,gr:"Γοργόνα με ψάρια",en:"Mermaid with fish",kind:.mermaid,variant:1),
            .init(id:19,gr:"Δράκος και σπηλιά",en:"Dragon and cave",kind:.dragon,variant:0),
            .init(id:20,gr:"Δράκος μπροστά στο κάστρο",en:"Dragon at the castle",kind:.dragon,variant:1),
            .init(id:21,gr:"Φοίνικας πουλί",en:"Phoenix bird",kind:.phoenix,variant:0),
            .init(id:22,gr:"Φοίνικας πάνω από βουνά",en:"Phoenix over mountains",kind:.phoenix,variant:1),
            .init(id:23,gr:"Νεράιδα στο δάσος",en:"Fairy in the forest",kind:.fairy,variant:0),
            .init(id:24,gr:"Μαγικό δεντρόσπιτο",en:"Magic treehouse",kind:.fairy,variant:1),
            .init(id:25,gr:"Καταρράκτης και βουνά",en:"Waterfall and mountains",kind:.landscape,variant:0),
            .init(id:26,gr:"Τοπίο με αερόστατα",en:"Hot-air balloon landscape",kind:.landscape,variant:1),
            .init(id:27,gr:"Σπιτάκι στο δάσος",en:"Forest cottage",kind:.landscape,variant:2),
            .init(id:28,gr:"Πειρατικό καράβι",en:"Pirate ship",kind:.pirate,variant:0),
            .init(id:29,gr:"Μικρός πειρατής και θησαυρός",en:"Little pirate and treasure",kind:.pirate,variant:1)
        ]
    }
}

private struct Studio2PKCanvas: UIViewRepresentable {
    @Binding var canvas: PKCanvasView
    func makeUIView(context: Context) -> PKCanvasView { canvas }
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

private struct FantasyColoringLineArt: View {
    let kind: Studio2PageKind
    let variant: Int
    var body: some View {
        Canvas { context, size in
            let ink = Color.black
            let lw = max(1.4, min(size.width, size.height) * 0.007)
            func stroke(_ path: Path, _ width: CGFloat? = nil) { context.stroke(path, with: .color(ink), style: StrokeStyle(lineWidth: width ?? lw, lineCap: .round, lineJoin: .round)) }
            func ellipse(_ rect: CGRect) { var p = Path(); p.addEllipse(in: rect); stroke(p) }
            func castle() {
                let y = size.height * 0.74
                let towerW = size.width * 0.16
                for x in [size.width*0.18, size.width*0.66] {
                    var p = Path(); p.addRect(CGRect(x:x,y:y-size.height*0.37,width:towerW,height:size.height*0.37)); stroke(p)
                    var roof = Path(); roof.move(to: CGPoint(x:x-8,y:y-size.height*0.37)); roof.addLine(to: CGPoint(x:x+towerW/2,y:y-size.height*0.58)); roof.addLine(to: CGPoint(x:x+towerW+8,y:y-size.height*0.37)); roof.closeSubpath(); stroke(roof)
                }
                var keep = Path(); keep.addRect(CGRect(x:size.width*0.34,y:y-size.height*0.46,width:size.width*0.32,height:size.height*0.46)); stroke(keep)
                for i in 0..<4 { let x = size.width*(0.35 + Double(i)*0.08); var merlon = Path(); merlon.addRect(CGRect(x:x,y:y-size.height*0.49,width:size.width*0.045,height:size.height*0.04)); stroke(merlon) }
                var door = Path(); door.addRoundedRect(in:CGRect(x:size.width*0.445,y:y-size.height*0.18,width:size.width*0.11,height:size.height*0.18),cornerSize:CGSize(width:30,height:30)); stroke(door)
                for i in 0..<5 { let x = size.width*(0.12 + Double(i)*0.19); ellipse(CGRect(x:x,y:y+8,width:28,height:28)) }
            }
            func person(princess: Bool) {
                let cx = size.width*0.5, cy = size.height*0.35
                ellipse(CGRect(x:cx-34,y:cy-50,width:68,height:78))
                var hair = Path(); hair.move(to:CGPoint(x:cx-34,y:cy-20)); hair.addCurve(to:CGPoint(x:cx-48,y:cy+52),control1:CGPoint(x:cx-55,y:cy+2),control2:CGPoint(x:cx-54,y:cy+36)); hair.move(to:CGPoint(x:cx+34,y:cy-20)); hair.addCurve(to:CGPoint(x:cx+48,y:cy+52),control1:CGPoint(x:cx+55,y:cy+2),control2:CGPoint(x:cx+54,y:cy+36)); stroke(hair)
                if princess { var crown=Path(); crown.move(to:CGPoint(x:cx-24,y:cy-52)); crown.addLine(to:CGPoint(x:cx-15,y:cy-78)); crown.addLine(to:CGPoint(x:cx,y:cy-58)); crown.addLine(to:CGPoint(x:cx+15,y:cy-78)); crown.addLine(to:CGPoint(x:cx+24,y:cy-52)); stroke(crown) }
                var dress=Path(); dress.move(to:CGPoint(x:cx-28,y:cy+28)); dress.addLine(to:CGPoint(x:cx-85,y:size.height*0.76)); dress.addQuadCurve(to:CGPoint(x:cx+85,y:size.height*0.76),control:CGPoint(x:cx,y:size.height*0.82)); dress.addLine(to:CGPoint(x:cx+28,y:cy+28)); stroke(dress)
                ellipse(CGRect(x:cx-15,y:cy-12,width:7,height:7)); ellipse(CGRect(x:cx+9,y:cy-12,width:7,height:7))
                var smile=Path(); smile.move(to:CGPoint(x:cx-12,y:cy+7)); smile.addQuadCurve(to:CGPoint(x:cx+12,y:cy+7),control:CGPoint(x:cx,y:cy+16)); stroke(smile)
            }
            func animal(horn: Bool, wings: Bool = false) {
                ellipse(CGRect(x:size.width*0.28,y:size.height*0.38,width:size.width*0.38,height:size.height*0.25))
                ellipse(CGRect(x:size.width*0.58,y:size.height*0.30,width:size.width*0.18,height:size.height*0.17))
                if horn { var h=Path(); h.move(to:CGPoint(x:size.width*0.65,y:size.height*0.30)); h.addLine(to:CGPoint(x:size.width*0.69,y:size.height*0.18)); h.addLine(to:CGPoint(x:size.width*0.72,y:size.height*0.31)); stroke(h) }
                if wings { var w=Path(); w.move(to:CGPoint(x:size.width*0.42,y:size.height*0.42)); w.addCurve(to:CGPoint(x:size.width*0.30,y:size.height*0.20),control1:CGPoint(x:size.width*0.30,y:size.height*0.34),control2:CGPoint(x:size.width*0.28,y:size.height*0.24)); w.addCurve(to:CGPoint(x:size.width*0.48,y:size.height*0.40),control1:CGPoint(x:size.width*0.43,y:size.height*0.22),control2:CGPoint(x:size.width*0.50,y:size.height*0.31)); stroke(w) }
                for x in [0.34,0.45,0.58,0.66] { var leg=Path(); leg.move(to:CGPoint(x:size.width*x,y:size.height*0.58)); leg.addLine(to:CGPoint(x:size.width*x,y:size.height*0.76)); stroke(leg) }
            }
            func water() { for row in 0..<4 { var p=Path(); let y=size.height*(0.65+Double(row)*0.05); p.move(to:CGPoint(x:size.width*0.08,y:y)); var x=size.width*0.08; while x<size.width*0.92 { p.addQuadCurve(to:CGPoint(x:x+42,y:y),control:CGPoint(x:x+21,y:y-8)); x += 42 }; stroke(p,lw*0.7) } }
            func mountains() { var p=Path(); p.move(to:CGPoint(x:size.width*0.05,y:size.height*0.58)); p.addLine(to:CGPoint(x:size.width*0.24,y:size.height*0.22)); p.addLine(to:CGPoint(x:size.width*0.40,y:size.height*0.58)); p.addLine(to:CGPoint(x:size.width*0.60,y:size.height*0.25)); p.addLine(to:CGPoint(x:size.width*0.88,y:size.height*0.58)); stroke(p) }

            switch kind {
            case .castle: castle(); mountains()
            case .princess: castle(); person(princess:true)
            case .unicorn: animal(horn:true); mountains(); if variant % 2 == 1 { water() }
            case .mermaid: person(princess:false); water(); for i in 0..<5 { ellipse(CGRect(x:size.width*(0.12+Double(i)*0.16),y:size.height*(0.18+Double(i%2)*0.11),width:26,height:16)) }
            case .dragon: castle(); animal(horn:false,wings:true)
            case .phoenix: animal(horn:false,wings:true); mountains()
            case .fairy: person(princess:false); mountains(); for i in 0..<7 { ellipse(CGRect(x:size.width*(0.12+Double(i)*0.12),y:size.height*0.73,width:26,height:26)) }
            case .landscape: mountains(); water(); if variant == 1 { for x in [0.25,0.52,0.76] { ellipse(CGRect(x:size.width*x,y:size.height*0.18,width:62,height:82)) } }
            case .pirate: water(); var ship=Path(); ship.move(to:CGPoint(x:size.width*0.20,y:size.height*0.58)); ship.addLine(to:CGPoint(x:size.width*0.78,y:size.height*0.58)); ship.addLine(to:CGPoint(x:size.width*0.66,y:size.height*0.72)); ship.addLine(to:CGPoint(x:size.width*0.32,y:size.height*0.72)); ship.closeSubpath(); stroke(ship); var mast=Path(); mast.move(to:CGPoint(x:size.width*0.50,y:size.height*0.58)); mast.addLine(to:CGPoint(x:size.width*0.50,y:size.height*0.22)); mast.addLine(to:CGPoint(x:size.width*0.68,y:size.height*0.34)); mast.addLine(to:CGPoint(x:size.width*0.50,y:size.height*0.34)); stroke(mast)
            case .capybara: EmptyView()
            }
        }
        .aspectRatio(4/3, contentMode: .fit)
        .background(.white)
    }
}
