import Foundation
import FirebaseFirestore

struct Application: Identifiable, Codable {
    enum CodingKeys: String, CodingKey {
        case id, eventID, eventTitle, volunteerID, volunteerEmail, status
        case appliedAt
        case volunteerName
        case message
    }

    var id: String?
    var eventID: String
    var eventTitle: String
    var volunteerID: String
    var volunteerEmail: String?
    var volunteerName: String?
    var status: String
    var appliedAt: Date
    var message: String?

    init(id: String? = nil,
         eventID: String,
         eventTitle: String,
         volunteerID: String,
         volunteerEmail: String? = nil,
         volunteerName: String? = nil,
         status: String = "Pending",
         appliedAt: Date = Date(),
         message: String? = nil) {
        self.id = id
        self.eventID = eventID
        self.eventTitle = eventTitle
        self.volunteerID = volunteerID
        self.volunteerEmail = volunteerEmail
        self.volunteerName = volunteerName
        self.status = status
        self.appliedAt = appliedAt
        self.message = message
    }

    static func fromDocument(_ doc: DocumentSnapshot) -> Application? {
        let data = doc.data() ?? [:]

        guard let eventID = data["eventID"] as? String,
              let eventTitle = data["eventTitle"] as? String,
              let volunteerID = data["volunteerID"] as? String,
              let status = data["status"] as? String
        else {
            return nil
        }

        var appliedAt: Date = Date()
        if let ts = data["appliedAt"] as? Timestamp {
            appliedAt = ts.dateValue()
        } else if let d = data["appliedAt"] as? Date {
            appliedAt = d
        } else if let s = data["appliedAt"] as? String, let parsed = ISO8601DateFormatter().date(from: s) {
            appliedAt = parsed
        }

        let volunteerEmail = data["volunteerEmail"] as? String
        let volunteerName = data["volunteerName"] as? String
        let message = data["message"] as? String

        return Application(id: doc.documentID,
                           eventID: eventID,
                           eventTitle: eventTitle,
                           volunteerID: volunteerID,
                           volunteerEmail: volunteerEmail,
                           volunteerName: volunteerName,
                           status: status,
                           appliedAt: appliedAt,
                           message: message)
    }
}
