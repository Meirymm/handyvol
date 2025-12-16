import SwiftUI

struct FilterView: View {
    @Binding var selectedLocation: String
    @Binding var selectedTags: [String]
    let availableTags: [String]
    let onApply: () -> Void
    
    @State private var internalSelectedTags: Set<String>

    init(selectedLocation: Binding<String>, selectedTags: Binding<[String]>, availableTags: [String], onApply: @escaping () -> Void) {
        self._selectedLocation = selectedLocation
        self._selectedTags = selectedTags
        self.availableTags = availableTags
        self.onApply = onApply
        self._internalSelectedTags = State(initialValue: Set(selectedTags.wrappedValue))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedStringKey("location_filter_title"))) {
                    TextField(LocalizedStringKey("location_filter_placeholder"), text: $selectedLocation)
                }
                
                Section(header: Text(LocalizedStringKey("tags_filter_title"))) {
                    VStack(alignment: .leading) {
                        FlowLayout(items: availableTags) { tag in
                            TagButton(tag: tag, isSelected: internalSelectedTags.contains(tag)) {
                                if internalSelectedTags.contains(tag) {
                                    internalSelectedTags.remove(tag)
                                } else {
                                    internalSelectedTags.insert(tag)
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button(LocalizedStringKey("apply_filters_button")) {
                        selectedTags = Array(internalSelectedTags)
                        onApply()
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("filters_title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("reset_filters_button")) {
                        selectedLocation = ""
                        internalSelectedTags = []
                        selectedTags = []
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("close_button")) { onApply() }
                }
            }
        }
    }
}


struct FlowLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content

    var body: some View {
        VStack(alignment: .leading) {
             HStack {
                 ForEach(Array(items), id: \.self) { item in
                     content(item)
                 }
                 .lineLimit(1)
             }
        }
    }
}
