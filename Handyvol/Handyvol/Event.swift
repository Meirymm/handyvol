
import Foundation
import FirebaseFirestore

extension Event {
    static func fromDocument(_ doc: DocumentSnapshot) -> Event? {
        let data = doc.data() ?? [:]

        guard let title = data["title"] as? String,
              let description = data["description"] as? String,
              let location = data["location"] as? String,
              let organizerID = data["organizerID"] as? String,
              let organizerName = data["organizerName"] as? String,
              let status = data["status"] as? String
        else {
            return nil
        }

        let id = doc.documentID
        
        let tags: [String] = data["tags"] as? [String] ?? ["General"]

        let requiredVolunteers = data["requiredVolunteers"] as? Int ?? 1
        let appliedVolunteers = data["appliedVolunteers"] as? Int ?? 0

        var date: Date = Date()
        if let ts = data["date"] as? Timestamp {
            date = ts.dateValue()
        } else if let d = data["date"] as? Date {
            date = d
        } else if let s = data["date"] as? String, let parsed = ISO8601DateFormatter().date(from: s) {
            date = parsed
        }

        let imageURL = data["imageURL"] as? String

        return Event(id: id,
                     title: title,
                     description: description,
                     location: location,
                     date: date,
                     requiredVolunteers: requiredVolunteers,
                     appliedVolunteers: appliedVolunteers,
                     tags: tags,
                     organizerID: organizerID,
                     organizerName: organizerName,
                     imageURL: imageURL,
                     status: status)
    }
}
