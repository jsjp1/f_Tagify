import SwiftUI

struct ShareExtensionView: View {
    let sharedText: String
    var onSave: (String, String, String) -> Void
    var onCancel: () -> Void

    @State private var title: String = ""
    @State private var description: String
    @State private var tags: String = ""
    @State private var userTags: [String] = []

    init(sharedText: String, onSave: @escaping (String, String, String) -> Void, onCancel: @escaping () -> Void) {
        self.sharedText = sharedText
        self._description = State(initialValue: sharedText)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text(NSLocalizedString("shared_url", comment: "Shared URL label"))
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Text(description)
                            .font(.callout)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                    }

                    Group {
                        Text(NSLocalizedString("title_label", comment: "Title label"))
                            .font(.caption)
                            .foregroundColor(.gray)

                        TextField(NSLocalizedString("title_placeholder", comment: "Title placeholder"), text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay(
                                HStack {
                                    Spacer()
                                    if !title.isEmpty {
                                        Button(action: { title = "" }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.trailing, 8)
                                    }
                                }
                            )
                    }

                    Group {
                        Text(NSLocalizedString("tags_label", comment: "Tags label"))
                            .font(.caption)
                            .foregroundColor(.gray)

                        TextField(NSLocalizedString("tags_placeholder", comment: "Tags placeholder"), text: $tags)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay(
                                HStack {
                                    Spacer()
                                    if !tags.isEmpty {
                                        Button(action: { tags = "" }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.trailing, 8)
                                    }
                                }
                            )
                    }

                    if !userTags.isEmpty {
                        Text(NSLocalizedString("my_tags", comment: "My tags section title"))
                            .font(.caption)
                            .foregroundColor(.gray)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(userTags, id: \.self) { tag in
                                    Button(action: {
                                        addTagToTextField(tag)
                                    }) {
                                        Text("\(tag)")
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.gray.opacity(0.15))
                                            .foregroundColor(.blue)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 8)
                    }

                    Button(action: {
                        onSave(title, description, tags)
                    }) {
                        Text(NSLocalizedString("save_button", comment: "Save button"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 12)
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
            .navigationTitle(NSLocalizedString("share_to_tagify", comment: "Navigation title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel_button", comment: "Cancel button")) {
                        onCancel()
                    }
                }
            }
            .onAppear(perform: loadUserTags)
        }
    }

    private func loadUserTags() {
        let userDefaults = UserDefaults(suiteName: "group.com.ellipsoid.tagi")
        userTags = userDefaults?.stringArray(forKey: "user_tags") ?? []
    }

    private func addTagToTextField(_ tag: String) {
        let currentTags = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        if !currentTags.contains(tag) {
            if tags.isEmpty {
                tags = tag
            } else {
                tags += ", \(tag)"
            }
        }
    }
}