import Foundation

struct Coordinates: Codable {
    let latitude:Double
    let longitude:Double
}

struct Location : Codable {
    let id:Int
    let user_id:Int?
    let name:String
    let isIndoor:Bool
    let coordinates:Coordinates
    
    let photo:String?
    let description:String?
    let instructions:String?
    let isPrivate:Bool?
    let number_of_tables:Int?
    let address:String?    
    let created_at:Date?
    let updated_at:Date?
    
    static func fake() -> Location {
        Location(
            id: 5,
            user_id: 2,
            name: "Cal Gallifa",
            isIndoor: false,
            coordinates:
                Coordinates(
                    latitude: 41.7439794,
                    longitude:  1.8071739
                ),
            photo: "https://pongmatch.app/storage/locations/3zBDAAzPDz8fqhWG.jpg",
            description: "Interessant per passar-ho bé amb els amics i altres persones que pots trobar per el carrer",
            instructions: nil,
            isPrivate: false, number_of_tables: 2,
            address: "Plaça Gallifa, Sant Joan de Vilatorrada, 08251",
            created_at: nil,
            updated_at: nil
        )
    }
}
