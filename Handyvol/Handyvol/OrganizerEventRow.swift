import SwiftUI

struct OrganizerEventRow: View {
    let event: Event
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        
        
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text(event.title)
                    .font(.headline)
                
                Text("Дата: \(event.date, style: .date)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(NSLocalizedString("status", comment: "") + ": \(event.status)")
                    .font(.subheadline)
                    .foregroundColor(event.status == "Open" ? .green : .red)
            }
            
            Spacer()

            if let id = event.id, id.isEmpty {
                 Text(LocalizedStringKey("loading_id")).foregroundColor(.secondary).font(.caption)
            }
            
            Menu {
                Button(LocalizedStringKey("edit_button"), action: onEdit)
                Button(LocalizedStringKey("delete_button"), role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            
            .contentShape(Rectangle())
            .onTapGesture {
            }
        }
    }
}
