import SwiftUI

struct CreateEventView: View {
    
    @StateObject var organizerService = OrganizerService()
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var date = Date()
    @State private var location: String = ""
    @State private var requiredVolunteers: Int = 1
    @State private var selectedTags: [String] = []
    
    let availableTags = ["Ecology", "Social", "Education", "Health", "Animals", "Culture", "Sport"]
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                // MARK: Event Details
                Section(header: Text(LocalizedStringKey("event_details"))) {

                    TextField(LocalizedStringKey("title_placeholder"), text: $title)
                        
                    TextField(LocalizedStringKey("description_placeholder"), text: $description, axis: .vertical)
                        .lineLimit(5, reservesSpace: true)

                    DatePicker(LocalizedStringKey("date_label"), selection: $date, displayedComponents: .date)
                    TextField(LocalizedStringKey("location_placeholder"), text: $location)
                }
                
                // MARK: Tags Selection
                Section(header: Text("Tags")) {
                    VStack(alignment: .leading) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(availableTags, id: \.self) { tag in
                                    TagButton(tag: tag, isSelected: selectedTags.contains(tag)) {
                                        toggleTag(tag)
                                    }
                                }
                            }
                        }
                    }
                    
                    Text("Selected: \(selectedTags.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .opacity(selectedTags.isEmpty ? 1 : 0)
                }
                
                // MARK: Volunteer Requirements
                Section(header: Text(LocalizedStringKey("volunteer_requirements"))) {
                    Stepper(value: $requiredVolunteers, in: 1...100) {
                        Text(NSLocalizedString("required_volunteers", comment: "") + ": \(requiredVolunteers)")
                    }
                }
                
                if let error = organizerService.errorMessage {
                    Text(error).foregroundColor(.red)
                }
            }
            .navigationTitle(LocalizedStringKey("create_event_title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("create_button")) {
                        Task {
                            let newEvent = Event(
                                title: title,
                                description: description,
                                location: location,
                                date: date,
                                requiredVolunteers: requiredVolunteers,
                                tags: selectedTags,
                                organizerID: "",
                                organizerName: "",
                                status: "Open"
                            )
                            await organizerService.createEvent(event: newEvent)
                            if organizerService.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                              description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                              location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                              selectedTags.isEmpty)
                }
            }
        }
    }
    
    func toggleTag(_ tag: String) {
        if let index = selectedTags.firstIndex(of: tag) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
    }
}
