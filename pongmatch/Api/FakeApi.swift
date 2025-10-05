import Foundation

class FakeApi : Api {
    override var me: Api.Me               { FakeApiMe(client: client) }
    override var locations: Api.Locations { FakeApiLocations(client: client) }
}

class FakeApiLocations : Api.Locations {
    
    override func near(latitude: Double, longitude: Double) async throws -> [Location] {
        return [
            Location(
                id: 1,
                user_id: 1,
                name: "Casa el Jordi P",
                isIndoor: true,
                coordinates:
                    Coordinates(
                        latitude: 41.757263183594,
                        longitude: 1.8311178684235
                    ),
                photo: "https://pongmatch.app/storage/locations/3zBDAAzPDz8fqhWG.jpg",
                description: "Supersecret",
                instructions: nil,
                isPrivate: true, number_of_tables: 2,
                address: "C/Alzina 11, Sant Fruitós de Bages, 08272",
                created_at: nil,
                updated_at: nil
            )
            ,
            Location(
                id: 4,
                user_id: 1,
                name: "Revo",
                isIndoor: true,
                coordinates:
                    Coordinates(
                        latitude: 41.7226538,
                        longitude: 1.8178933
                    ),
                photo: "https://pongmatch.app/storage/locations/zsdBCWAdx8YpgoxT.jpg",
                description: "Molt Xula",
                instructions: "Truca per entrar",
                isPrivate: false, number_of_tables: 2,
                address: "C/Arquitecte Oms 2",
                created_at: nil,
                updated_at: nil
            ),
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
            
        ]
    }
    
    override func get(id:Int) async throws -> Location {
        try await near(latitude: 0, longitude: 0).first { $0.id == id }!
    }
}

class FakeApiMe : Api.Me {
    override func deleteAccount() async throws {
        
    }
}


class FakeApiTorunaments : Api.Tournaments {
    override func index() async throws -> [Tournament] {
        [
            Tournament(
                id: 1,
                name: "Primer torunament",
                information: nil,
                token: "ABCDEF",
                initial_score: .standard,
                ranking_type: .competitive,
                winning_condition: .single,
                status: .started,
                photo: nil,
                date: Date(),
                entry_max_players_slots: 100,
                entry_min_elo: 1400,
                entry_max_elo: 1800,
                user: User.me(),
                winner: User.opponent(),
                location: nil,
                created_at: Date(),
                updated_at: Date()
            ),
            Tournament(
                id: 1,
                name: "Second Tournament",
                information: nil,
                token: "FEDABC",
                initial_score: .standard,
                ranking_type: .competitive,
                winning_condition: .bestof3,
                status: .draft,
                photo: nil,
                date: Date(),
                entry_max_players_slots: 12,
                entry_min_elo: nil,
                entry_max_elo: nil,
                user: User.me(),
                winner: nil,
                location: nil,
                created_at: Date(),
                updated_at: Date()
            )
        ]
    }
}
