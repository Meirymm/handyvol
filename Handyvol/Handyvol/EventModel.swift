import Foundation
import FirebaseFirestore

struct Event: Identifiable, Codable {
    
    var requiredVolunteers: Int
    var appliedVolunteers: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, location, tags, organizerID, organizerName, imageURL, status
        case date
        case requiredVolunteers
        case appliedVolunteers
    }
    
    var id: String?
    var title: String
    var description: String
    var location: String
    var date: Date
    var tags: [String]
    var organizerID: String
    var organizerName: String
    var imageURL: String?
    var status: String
    var createdAt: Date?
    init(id: String? = nil,
         title: String,
         description: String,
         location: String,
         date: Date,
         requiredVolunteers: Int,
         appliedVolunteers: Int = 0,
         tags: [String],
         organizerID: String,
         organizerName: String,
         imageURL: String? = nil,
         status: String) {
        self.id = id
        self.title = title
        self.description = description
        self.location = location
        self.date = date
        self.requiredVolunteers = requiredVolunteers
        self.appliedVolunteers = appliedVolunteers
        self.tags = tags
        self.organizerID = organizerID
        self.organizerName = organizerName
        self.imageURL = imageURL
        self.status = status
    }
}
