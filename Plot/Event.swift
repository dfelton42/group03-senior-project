import Foundation
import CoreLocation

struct Event: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let date: Date
    
    // Optional DB fields (Supabase returns null)
    let latitude: Double?
    let longitude: Double?
    
    // RSVPs stored as Int? because Supabase may return null
    let rsvps: Int?
    
    // Updated field names (snake_case → camelCase)
    let upvoteCount: Int?
    let downvoteCount: Int?

    // Convenience: coordinate for MapKit
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude ?? 0,
            longitude: longitude ?? 0
        )
    }

    // Map DB column names to Swift properties
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case date
        case latitude
        case longitude
        case rsvps
        case upvoteCount = "upvote_count"
        case downvoteCount = "downvote_count"
    }
}

