import SwiftUI

struct EditEventView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var event: Event
    
    @StateObject var organizerService = OrganizerService()

    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedStringKey("event_details"))) {
                    // Заголовок
                    TextField(LocalizedStringKey("title_placeholder"), text: $event.title)
                    
                    // Описание
                    TextField(LocalizedStringKey("description_placeholder"), text: $event.description, axis: .vertical)
                        .lineLimit(5, reservesSpace: true)
                    
                    // Дата
                    DatePicker(LocalizedStringKey("date_label"), selection: $event.date, displayedComponents: .date)
                    
                    // Местоположение
                    TextField(LocalizedStringKey("location_placeholder"), text: $event.location)
                }
                
                Section(header: Text(LocalizedStringKey("volunteer_requirements"))) {
                    Stepper(value: $event.requiredVolunteers, in: 1...100) {
                        Text(NSLocalizedString("required_volunteers", comment: "") + ": \(event.requiredVolunteers)")
                    }
                    
                    // Статус волонтеров (отображение)
                    Text(NSLocalizedString("applied_volunteers", comment: "") + ": \(event.appliedVolunteers)")
                        .foregroundColor(.secondary)
                }
                
                // Отображение ошибки
                if let error = organizerService.errorMessage {
                    Text(error).foregroundColor(.red)
                }
            }
            .navigationTitle(LocalizedStringKey("edit_event_title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("cancel_button")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("save_button")) {
                        Task {
                            // Отправляем обновленное событие
                            await organizerService.updateEvent(event: event)
                            
                            if organizerService.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(event.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || organizerService.isLoading)
                }
            }
        }
    }
}
