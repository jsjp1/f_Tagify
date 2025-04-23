import SwiftUI

struct ShareExtensionView: View {
    let sharedText: String
    var onSave: (String, String, String) -> Void
    var onCancel: () -> Void  

    @State private var title: String = ""
    @State private var description: String
    @State private var tags: String = ""

    init(sharedText: String, onSave: @escaping (String, String, String) -> Void, onCancel: @escaping () -> Void) {
        self.sharedText = sharedText
        self._description = State(initialValue: sharedText)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text(NSLocalizedString("url", comment: "URL label"))
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(description)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .frame(height: 45)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)

                TextField(NSLocalizedString("title", comment: "Title field"), text: $title)
                    .textFieldStyle(.roundedBorder)
                    .padding(.top, 8)

                TextField(NSLocalizedString("tags", comment: "Tags field"), text: $tags)
                    .textFieldStyle(.roundedBorder)

                Button(NSLocalizedString("save", comment: "Save button")) {
                    onSave(title, description, tags)
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                Spacer()
            }
            .padding()
            .navigationTitle(NSLocalizedString("share_to_tagify", comment: "Navigation title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "Cancel button")) {
                        onCancel() 
                    }
                }
            }
        }
    }
}