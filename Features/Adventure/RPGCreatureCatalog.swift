import Foundation

struct RPGCreatureDefinition: Identifiable, Hashable {
    let id: String
    let asset: String
    let greekName: String
    let englishName: String
    let collisionScale: Double

    init(_ id: String, greek: String, english: String, collisionScale: Double = 0.68) {
        self.id = id
        self.asset = "\(id)_rpg_neutral"
        self.greekName = greek
        self.englishName = english
        self.collisionScale = collisionScale
    }
}

enum RPGCreatureCatalog {
    static let all: [RPGCreatureDefinition] = [
        .init("triceratops", greek: "Τρικεράτοπας", english: "Triceratops", collisionScale: 0.82),
        .init("stegosaurus", greek: "Στεγόσαυρος", english: "Stegosaurus", collisionScale: 0.84),
        .init("ankylosaurus", greek: "Αγκυλόσαυρος", english: "Ankylosaurus", collisionScale: 0.84),
        .init("parasaurolophus", greek: "Παρασαυρόλοφος", english: "Parasaurolophus", collisionScale: 0.80),
        .init("brachiosaurus", greek: "Βραχιόσαυρος", english: "Brachiosaurus", collisionScale: 0.82),
        .init("velociraptor", greek: "Βελοσιράπτορας", english: "Velociraptor", collisionScale: 0.72),
        .init("trex", greek: "Τυραννόσαυρος", english: "T-Rex", collisionScale: 0.82),
        .init("spinosaurus", greek: "Σπινόσαυρος", english: "Spinosaurus", collisionScale: 0.84),
        .init("pteranodon", greek: "Πτερανόδοντας", english: "Pteranodon", collisionScale: 0.68),
        .init("dilophosaurus", greek: "Διλοφόσαυρος", english: "Dilophosaurus", collisionScale: 0.74),
        .init("iguanodon", greek: "Ιγκουανόδοντας", english: "Iguanodon", collisionScale: 0.80),
        .init("pachycephalosaurus", greek: "Παχυκεφαλόσαυρος", english: "Pachycephalosaurus", collisionScale: 0.76),
        .init("bear", greek: "Αρκούδα", english: "Bear", collisionScale: 0.76),
        .init("deer", greek: "Ελάφι", english: "Deer"), .init("hedgehog", greek: "Σκαντζόχοιρος", english: "Hedgehog"),
        .init("squirrel", greek: "Σκίουρος", english: "Squirrel"), .init("owl", greek: "Κουκουβάγια", english: "Owl"),
        .init("frog", greek: "Βάτραχος", english: "Frog"), .init("raccoon", greek: "Ρακούν", english: "Raccoon"),
        .init("badger", greek: "Ασβός", english: "Badger"), .init("beaver", greek: "Κάστορας", english: "Beaver"),
        .init("otter", greek: "Βίδρα", english: "Otter"), .init("turtle", greek: "Χελώνα", english: "Turtle"),
        .init("mouse", greek: "Ποντικάκι", english: "Mouse"), .init("butterfly", greek: "Πεταλούδα", english: "Butterfly", collisionScale: 0.45),
        .init("bee", greek: "Μέλισσα", english: "Bee", collisionScale: 0.45), .init("ladybug", greek: "Πασχαλίτσα", english: "Ladybug", collisionScale: 0.45),
        .init("dragonfly", greek: "Λιβελούλα", english: "Dragonfly", collisionScale: 0.45), .init("grasshopper", greek: "Ακρίδα", english: "Grasshopper", collisionScale: 0.45),
        .init("snail", greek: "Σαλιγκάρι", english: "Snail", collisionScale: 0.50), .init("caterpillar", greek: "Κάμπια", english: "Caterpillar", collisionScale: 0.48),
        .init("firefly", greek: "Πυγολαμπίδα", english: "Firefly", collisionScale: 0.40),
        .init("baby_dragon", greek: "Μικρός Δράκος", english: "Baby Dragon", collisionScale: 0.72),
        .init("pegasus", greek: "Πήγασος", english: "Pegasus", collisionScale: 0.76),
        .init("forest_fairy", greek: "Νεράιδα του Δάσους", english: "Forest Fairy", collisionScale: 0.50),
        .init("forest_spirit", greek: "Πνεύμα του Δάσους", english: "Forest Spirit", collisionScale: 0.70)
    ]

    private static let byID = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
    static func creature(_ id: String) -> RPGCreatureDefinition? { byID[id] }

    static func population(for area: RPGArea) -> [String] {
        switch area {
        case .forest: return ["deer", "squirrel", "hedgehog", "butterfly", "bee", "owl", "mouse"]
        case .rescueClearing: return ["rabbit", "deer", "raccoon", "badger", "frog", "ladybug", "butterfly"]
        case .village: return ["beaver", "otter", "turtle", "squirrel", "raccoon", "owl", "mouse"]
        case .riverCrossing: return ["beaver", "otter", "frog", "turtle", "dragonfly", "snail", "deer"]
        case .puzzleClearing: return ["triceratops", "stegosaurus", "ankylosaurus", "iguanodon", "pachycephalosaurus", "butterfly"]
        case .crystalCave: return ["velociraptor", "dilophosaurus", "baby_dragon", "firefly", "forest_spirit", "snail"]
        case .nightForest: return ["owl", "badger", "raccoon", "firefly", "forest_spirit", "mouse", "hedgehog"]
        case .unicornGrove: return ["pegasus", "forest_fairy", "forest_spirit", "butterfly", "bee", "deer", "baby_dragon"]
        case .treasureClearing: return ["trex", "spinosaurus", "brachiosaurus", "parasaurolophus", "pteranodon", "triceratops"]
        case .foxDen: return ["forest_spirit", "owl", "firefly", "badger", "raccoon", "baby_dragon"]
        }
    }
}
