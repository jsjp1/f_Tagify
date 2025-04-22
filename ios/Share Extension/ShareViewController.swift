import SwiftUI
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSwiftUIView()
    }
    
    func setupSwiftUIView() {
        var sharedText = "기본 텍스트"
        
        if let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
           let itemProvider = extensionItem.attachments?.first {
            
            let textType = UTType.plainText.identifier
            let urlType = UTType.url.identifier
            
            if itemProvider.hasItemConformingToTypeIdentifier(textType) {
                itemProvider.loadItem(forTypeIdentifier: textType, options: nil) { (item, error) in
                    DispatchQueue.main.async {
                        if let text = item as? String {
                            sharedText = text
                            self.showShareUI(with: sharedText)
                        } else {
                            self.showShareUI(with: sharedText)
                        }
                    }
                }
            } 
            else if itemProvider.hasItemConformingToTypeIdentifier(urlType) {
                itemProvider.loadItem(forTypeIdentifier: urlType, options: nil) { (item, error) in
                    DispatchQueue.main.async {
                        if let url = item as? URL {
                            sharedText = url.absoluteString
                            self.showShareUI(with: sharedText)
                        } else {
                            self.showShareUI(with: sharedText)
                        }
                    }
                }
            } else {
                showShareUI(with: sharedText)
            }
        } else {
            showShareUI(with: sharedText)
        }
    }
    
    func showShareUI(with text: String) {
        let shareView = ShareExtensionView(sharedText: text) { title, description, tags in
            self.saveSharedItem(title: title, description: description, tags: tags)
            self.openMainApp()
        }
        
        let hostingController = UIHostingController(rootView: shareView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    private func saveSharedItem(title: String, description: String, tags: String) {
        let userDefaults = UserDefaults(suiteName: "group.com.ellipsoid.tagi")
        var items = userDefaults?.array(forKey: "sharedItems") as? [[String: String]] ?? []

        let newItem: [String: String] = [
            "url": description,
            "title": title.isEmpty ? "" : title,
            "body": description,
            "tags": tags
        ]

        items.append(newItem)
        userDefaults?.set(items, forKey: "sharedItems")
    }

    private func openMainApp() {
        guard let url = URL(string: "tagify://shared") else {
            extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            return
        }

        var responder: UIResponder? = self
        while responder != nil {
            if let app = responder as? UIApplication {
                app.performSelector(onMainThread: NSSelectorFromString("openURL:"), with: url, waitUntilDone: false)
                break
            }
            responder = responder?.next
        }

        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    func close() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}