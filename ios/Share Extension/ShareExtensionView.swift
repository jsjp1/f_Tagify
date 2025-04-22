import SwiftUI

struct ShareExtensionView: View {
    let sharedText: String
    var onSave: (String, String, String) -> Void

    @State private var title: String = ""
    @State private var description: String
    @State private var tags: String = ""

    init(sharedText: String, onSave: @escaping (String, String, String) -> Void) {
        self.sharedText = sharedText
        self._description = State(initialValue: sharedText)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView { // iOS 15 이하용 - 16 이상은 NavigationStack
            VStack(alignment: .leading, spacing: 16) {
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .padding(.top, 8)

                Text("URL")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(description)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .frame(height: 120)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)

                TextField("Tags (comma-separated)", text: $tags)
                    .textFieldStyle(.roundedBorder)

                Button("Save") {
                    onSave(title, description, tags)
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                Spacer()
            }
            .padding()
            .navigationTitle("Share to Tagify")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // 직접 NotificationCenter 대신 클로저로 처리
                        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
                    }
                }
            }
        }
    }
}