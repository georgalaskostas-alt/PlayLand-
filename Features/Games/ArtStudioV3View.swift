import SwiftUI
import PencilKit

struct ArtStudioV3View: View {
    @EnvironmentObject private var appSettings: AppSettings
    @State private var mode: ArtV3Mode?
    @State private var showLegacy = false
    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.purple.opacity(0.86), .blue.opacity(0.80)], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    Text("🎨").font(.system(size: 54))
                    Text(isGreek ? "Εργαστήριο Ζωγραφικής" : "Art Studio")
                        .font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(.white)
                    Text(isGreek ? "Με τα 30 νέα σκίτσα που διάλεξες" : "With your 30 new selected drawings")
                        .font(.headline.weight(.bold)).foregroundStyle(.white.opacity(0.9))
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        card(.free, "✏️", isGreek ? "Ελεύθερη Ζωγραφική" : "Free Draw")
                        card(.trace, "🪄", isGreek ? "Ζωγράφισε με Οδηγό" : "Trace & Draw")
                        card(.color, "🖍️", isGreek ? "Χρωμάτισε" : "Coloring Book")
                        card(.challenge, "🎯", isGreek ? "Πρόκληση" : "Challenge")
                    }
                    Button { showLegacy = true } label: {
                        Label(isGreek ? "Προηγούμενα σχέδια" : "Previous drawings", systemImage: "books.vertical.fill")
                            .font(.headline.weight(.black)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(16)
                            .background(.black.opacity(0.25)).clipShape(RoundedRectangle(cornerRadius: 18))
                    }.buttonStyle(.plain)
                }.padding(18)
            }
        }
        .fullScreenCover(item: $mode) { ArtV3Canvas(mode: $0).environmentObject(appSettings) }
        .fullScreenCover(isPresented: $showLegacy) { NavigationStack { ArtStudioFixedView().environmentObject(appSettings) } }
    }

    private func card(_ mode: ArtV3Mode, _ emoji: String, _ title: String) -> some View {
        Button { self.mode = mode } label: {
            VStack(spacing: 10) { Text(emoji).font(.system(size: 42)); Text(title).font(.headline.weight(.black)).multilineTextAlignment(.center) }
                .foregroundStyle(.white).frame(maxWidth: .infinity, minHeight: 138).padding(12)
                .background(.white.opacity(0.15)).overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.24))).clipShape(RoundedRectangle(cornerRadius: 22))
        }.buttonStyle(.plain)
    }
}

private enum ArtV3Mode: String, Identifiable { case free, trace, color, challenge; var id: String { rawValue } }
private enum ArtV3Tool: String, CaseIterable, Identifiable { case pencil, pen, marker, brush, eraser; var id: String { rawValue } }

private struct ArtV3Page: Identifiable {
    let id: Int; let gr: String; let en: String
}

private struct ArtV3Canvas: View {
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss
    let mode: ArtV3Mode
    @State private var canvas = PKCanvasView()
    @State private var tool: ArtV3Tool = .pencil
    @State private var colorID = "black"
    @State private var width: CGFloat = 7
    @State private var selectedPage = 0
    @State private var showPages = false
    @State private var guideOpacity = 0.24
    @State private var challenge = 0
    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }

    private let colors: [(id: String, swift: Color, ui: UIColor)] = [
        ("black", Color(red:0,green:0,blue:0), UIColor(red:0,green:0,blue:0,alpha:1)),
        ("white", Color(red:1,green:1,blue:1), UIColor(red:1,green:1,blue:1,alpha:1)),
        ("gray", .gray, .darkGray), ("red", .red, .systemRed), ("orange", .orange, .systemOrange),
        ("yellow", .yellow, .systemYellow), ("green", .green, .systemGreen), ("mint", .mint, .systemMint),
        ("cyan", .cyan, .systemCyan), ("blue", .blue, .systemBlue), ("purple", .purple, .systemPurple),
        ("pink", .pink, .systemPink), ("brown", .brown, .systemBrown)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if mode == .challenge { challengeHeader }
                ZStack {
                    Color.white
                    if mode == .trace || mode == .color {
                        ArtStudioExactPageView(index: selectedPage)
                            .opacity(mode == .trace ? guideOpacity : 1)
                            .padding(14).allowsHitTesting(false)
                    }
                    ArtV3PKCanvas(canvas: $canvas)
                }
                .clipShape(RoundedRectangle(cornerRadius: 18)).overlay(RoundedRectangle(cornerRadius: 18).stroke(.black.opacity(0.18))).padding(10)
                controls
            }
            .background(Color(red:0.95,green:0.93,blue:0.89).ignoresSafeArea())
            .navigationTitle(title).navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button { dismiss() } label: { Image(systemName:"xmark.circle.fill").font(.title2) } }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { canvas.undoManager?.undo() } label: { Image(systemName:"arrow.uturn.backward") }
                    Button { canvas.undoManager?.redo() } label: { Image(systemName:"arrow.uturn.forward") }
                    Button { canvas.drawing = PKDrawing() } label: { Image(systemName:"trash") }
                }
            }
            .sheet(isPresented: $showPages) { pagePicker }
            .onAppear { configureCanvas() }
            .onChange(of: tool) { _,_ in updateTool() }.onChange(of: colorID) { _,_ in updateTool() }.onChange(of: width) { _,_ in updateTool() }
        }
    }

    private var title: String {
        switch mode { case .free: return isGreek ? "Ελεύθερη Ζωγραφική" : "Free Draw"; case .trace: return isGreek ? "Ζωγράφισε με Οδηγό" : "Trace & Draw"; case .color: return isGreek ? "Χρωμάτισε" : "Coloring Book"; case .challenge: return isGreek ? "Πρόκληση Ζωγραφικής" : "Drawing Challenge" }
    }

    private var challengeHeader: some View {
        let gr = ["Ζωγράφισε ένα κάστρο με πριγκίπισσα","Ζωγράφισε ένα capybara στο δάσος","Ζωγράφισε έναν μονόκερο δίπλα σε καταρράκτη","Ζωγράφισε έναν φοίνικα που πετά","Ζωγράφισε μια γοργόνα στο παλάτι της"]
        let en = ["Draw a castle with a princess","Draw a capybara in the forest","Draw a unicorn by a waterfall","Draw a flying phoenix","Draw a mermaid in her palace"]
        return HStack { Text(isGreek ? gr[challenge] : en[challenge]).font(.headline.weight(.black)).multilineTextAlignment(.center); Button { challenge=(challenge+1)%gr.count } label:{ Image(systemName:"dice.fill") } }.padding(12).frame(maxWidth:.infinity).background(.yellow.opacity(0.25))
    }

    private var controls: some View {
        VStack(spacing: 10) {
            ScrollView(.horizontal, showsIndicators:false) { HStack(spacing:9) { ForEach(ArtV3Tool.allCases) { item in
                Button { tool=item } label: { VStack(spacing:3) { Image(systemName:icon(item)).font(.system(size:21,weight:.bold)); Text(name(item)).font(.caption2.weight(.black)) }.foregroundStyle(tool == item ? .white : .black).frame(width:72,height:58).background(tool == item ? Color.blue : Color.white).overlay(RoundedRectangle(cornerRadius:14).stroke(.black.opacity(0.25))).clipShape(RoundedRectangle(cornerRadius:14)) }.buttonStyle(.plain)
            }}.padding(.horizontal,10) }
            ScrollView(.horizontal, showsIndicators:false) {
                HStack(spacing:12) {
                    ForEach(colors,id:\.id) { item in
                        Button {
                            colorID=item.id
                            if tool == .eraser { tool = .pencil }
                            updateTool()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(item.swift)
                                    .frame(width:34,height:34)
                                Circle()
                                    .stroke(item.id == "white" ? Color.gray : Color.black.opacity(0.25),lineWidth:1.5)
                                    .frame(width:34,height:34)
                                if colorID == item.id {
                                    Circle()
                                        .stroke(Color.blue,lineWidth:3)
                                        .frame(width:40,height:40)
                                }
                            }
                            .frame(width:44,height:44)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(item.id)
                    }
                }
                .padding(.horizontal,12)
            }
            .frame(height:50)
            HStack { Image(systemName:"circle.fill").font(.system(size:7)); Slider(value:$width,in:2...30,step:1); Image(systemName:"circle.fill").font(.system(size:19)); if mode == .trace || mode == .color { Button { showPages=true } label:{ Label(isGreek ? "Σχέδιο" : "Picture",systemImage:"photo.on.rectangle") }.buttonStyle(.bordered) } }.padding(.horizontal,14)
            if mode == .trace { HStack { Image(systemName:"sun.min"); Slider(value:$guideOpacity,in:0.08...0.5); Image(systemName:"sun.max.fill") }.padding(.horizontal,14) }
        }.padding(.vertical,10).foregroundStyle(.black).background(Color(red:0.88,green:0.88,blue:0.88))
    }

    private func configureCanvas() { canvas.backgroundColor = .clear; canvas.isOpaque=false; canvas.drawingPolicy = .anyInput; canvas.minimumZoomScale=1; canvas.maximumZoomScale=3; updateTool() }
    private func updateTool() {
        if tool == .eraser { canvas.tool = PKEraserTool(.bitmap); return }
        let ink: PKInkingTool.InkType
        switch tool { case .pencil: ink = .pencil; case .pen: ink = .pen; case .marker: ink = .marker; case .brush: ink = .monoline; case .eraser: ink = .pen }
        let selected = colors.first(where:{$0.id == colorID}) ?? colors[0]
        canvas.tool = PKInkingTool(ink,color:selected.ui,width:width)
    }
    private func icon(_ t:ArtV3Tool)->String { switch t { case .pencil:return "pencil"; case .pen:return "pencil.tip"; case .marker:return "highlighter"; case .brush:return "paintbrush.pointed.fill"; case .eraser:return "eraser.fill" } }
    private func name(_ t:ArtV3Tool)->String { if isGreek { switch t { case .pencil:return "Μολύβι"; case .pen:return "Πένα"; case .marker:return "Μαρκαδ."; case .brush:return "Πινέλο"; case .eraser:return "Γόμα" } }; return t.rawValue.capitalized }

    private var pagePicker: some View {
        NavigationStack { ScrollView { LazyVGrid(columns:[GridItem(.adaptive(minimum:145),spacing:12)],spacing:12) { ForEach(pages) { page in
            Button { selectedPage=page.id; showPages=false; canvas.drawing=PKDrawing() } label: { VStack(spacing:7) { ArtStudioExactPageView(index:page.id).frame(height:105).padding(5).background(.white).clipped(); Text(isGreek ? page.gr : page.en).font(.caption.weight(.bold)).foregroundStyle(.black).lineLimit(2).multilineTextAlignment(.center) }.padding(8).background(.white).clipShape(RoundedRectangle(cornerRadius:16)) }.buttonStyle(.plain)
        }}.padding(14) }.background(Color(red:0.94,green:0.92,blue:0.88)).navigationTitle(isGreek ? "30 νέα σκίτσα" : "30 new drawings").toolbar { ToolbarItem(placement:.topBarTrailing) { Button(isGreek ? "Κλείσιμο" : "Done") { showPages=false } } } }
    }

    private var pages:[ArtV3Page] { [
        .init(id:0,gr:"Κάστρο των ονείρων",en:"Dream castle"), .init(id:1,gr:"Πριγκίπισσα στο μπαλκόνι",en:"Princess on the balcony"), .init(id:2,gr:"Πριγκίπισσα και το γατάκι της",en:"Princess and her kitten"),
        .init(id:3,gr:"Capybara στο δάσος",en:"Capybara in the forest"), .init(id:4,gr:"Capybara δίπλα στο ποτάμι",en:"Capybara by the river"), .init(id:5,gr:"Οικογένεια capybara",en:"Capybara family"),
        .init(id:6,gr:"Capybara με πεταλούδες",en:"Capybara with butterflies"), .init(id:7,gr:"Capybara κάτω από το δέντρο",en:"Capybara under the tree"), .init(id:8,gr:"Capybara στον καταρράκτη",en:"Capybara at the waterfall"),
        .init(id:9,gr:"Capybara με πουλάκια",en:"Capybara with birds"), .init(id:10,gr:"Capybara σε μαγικό δάσος",en:"Capybara in a magical forest"), .init(id:11,gr:"Capybara στη λίμνη",en:"Capybara in the lake"),
        .init(id:12,gr:"Μονόκερος στο λιβάδι",en:"Unicorn in the meadow"), .init(id:13,gr:"Μονόκερος και καταρράκτης",en:"Unicorn and waterfall"), .init(id:14,gr:"Μονόκερος στα σύννεφα",en:"Unicorn in the clouds"),
        .init(id:15,gr:"Γοργόνα και το παλάτι της",en:"Mermaid and her palace"), .init(id:16,gr:"Γοργόνα με φίλους",en:"Mermaid with friends"), .init(id:17,gr:"Δράκος και το σπήλαιο",en:"Dragon and cave"),
        .init(id:18,gr:"Νεράιδα στο δάσος",en:"Fairy in the forest"), .init(id:19,gr:"Μαγικό δεντρόσπιτο",en:"Magic treehouse"), .init(id:20,gr:"Πειρατικό καράβι",en:"Pirate ship"),
        .init(id:21,gr:"Μικρός πειρατής",en:"Little pirate"), .init(id:22,gr:"Παραλία με φοίνικα",en:"Beach with palm tree"), .init(id:23,gr:"Φοίνικας πουλί",en:"Phoenix bird"),
        .init(id:24,gr:"Ιππότης και κάστρο",en:"Knight and castle"), .init(id:25,gr:"Πριγκίπισσα και μονόκερος",en:"Princess and unicorn"), .init(id:26,gr:"Παλάτι στη λίμνη",en:"Palace by the lake"),
        .init(id:27,gr:"Τοπίο με αερόστατα",en:"Hot-air balloon landscape"), .init(id:28,gr:"Σπιτάκι στο δάσος",en:"Forest cottage"), .init(id:29,gr:"Χειμωνιάτικο κάστρο",en:"Winter castle")
    ] }
}

private struct ArtV3PKCanvas:UIViewRepresentable {
    @Binding var canvas:PKCanvasView
    func makeUIView(context:Context)->PKCanvasView { canvas }
    func updateUIView(_ uiView:PKCanvasView,context:Context) {}
}