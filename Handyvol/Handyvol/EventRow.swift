import SwiftUI

struct EventRow: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.title)
                .font(.headline)
            
            HStack {
                Image(systemName: "calendar")
                Text(event.date, style: .date)
                
                Spacer()
                
                Image(systemName: "mappin.and.ellipse")
                Text(event.location)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
        
            Text(event.tags
                .map { NSLocalizedString($0, comment: "Tag name") }
                .joined(separator: ", ")
            )
            
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}
