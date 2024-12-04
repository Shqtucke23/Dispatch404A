import Foundation

struct User: Codable, Identifiable {
    enum CodingKeys: CodingKey {
        case name, address, city, phone, brand, terminal, notes, comments, latitude, longitude
    }
    
    var id = UUID()
    var name: String = ""
    var address: String
    var city: String = ""
    var phone: String = ""
    var brand: String = ""
    var terminal: String = ""
    var notes: String = ""
    var comments: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
}

class ReadJsonData: ObservableObject {
    @Published var users = [User]()
    
    init() {
        loadData()
    }
    
    func loadData() {
        guard let url = Bundle.main.url(forResource: "data", withExtension: "json") else {
            print("Json file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedUsers = try JSONDecoder().decode([User].self, from: data)
            self.users = decodedUsers
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
}

