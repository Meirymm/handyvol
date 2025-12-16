import SwiftUI

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(displayStatus)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor(for: status))
            .cornerRadius(10)
    }
    
    private func backgroundColor(for status: String) -> Color {
        switch status {
        case "Pending":
            return .orange
        case "Approved":
            return .green
        case "Rejected":
            return .red
        default:
            return .gray
        }
    }
    
    private var displayStatus: String {
       
        return NSLocalizedString(status, comment: "").localizedCapitalized
    }
}
