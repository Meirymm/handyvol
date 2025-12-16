import SwiftUI

struct EventDetailView: View {
    let event: Event
    
    @ObservedObject var volunteerService: VolunteerService
    
    private var isApplied: Bool {
        return volunteerService.hasApplied(for: event.id ?? "")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text(event.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack {
                    Label(formattedDate(event.date), systemImage: "calendar")
                    Spacer()
                    Label(event.location, systemImage: "mappin.and.ellipse")
                }
                .foregroundColor(.secondary)
                
                Divider()
                
                Text(LocalizedStringKey("description_label"))
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(event.description)
                
                // 4. Теги
                if !event.tags.isEmpty {
                    Text(LocalizedStringKey("tags_label")) 
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack {
                        ForEach(event.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                        }
                    }
                }
                
                Spacer()
                
                if volunteerService.isLoading {
                    ProgressView(LocalizedStringKey("processing_application"))
                        .frame(maxWidth: .infinity)
                } else {
                    Button(action: handleApply) {
                        Text(isApplied ? LocalizedStringKey("applied_pending_text") : LocalizedStringKey("apply_button_text"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isApplied ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(isApplied)
                }
                
                if let error = volunteerService.errorMessage {
                    Text(error).foregroundColor(.red).padding(.top, 5)
                }
            }
            .padding()
        }
        .navigationTitle(LocalizedStringKey("event_details_title"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await volunteerService.fetchMyApplications()
            }
        }
    }
    
    func handleApply() {
        Task {
            await volunteerService.applyForEvent(event: event)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
