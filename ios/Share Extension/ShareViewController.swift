import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    private func extractURL(from text: String) -> String? {
        let pattern = #"https?://[^\s]+"#
        if let regex = try? NSRegularExpression(pattern: pattern),
        let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
        let range = Range(match.range, in: text) {
            return String(text[range])
        }
        return nil
    }

    let appGroupId = "group.com.ellipsoid.tagi"
    var tagText: String? = nil

    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem else {
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            return
        }

        let inputText = tagText ?? contentText
        let title = item.attributedContentText?.string ?? ""

        if let attachment = item.attachments?.first {
            // 1. Safari, Chrome, ...
            if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                attachment.loadItem(forTypeIdentifier: kUTTypeURL as String) { (data, error) in
                    if let url = data as? URL {
                        self.saveSharedItem(url: url.absoluteString, title: title, tags: inputText)
                    }
                    self.openMainApp()
                }
                return
            }

            // 2. Youtube Mobile Application
            if attachment.hasItemConformingToTypeIdentifier("public.plain-text") {
                attachment.loadItem(forTypeIdentifier: "public.plain-text", options: nil) { (data, error) in
                    if let text = data as? String, let urlString = self.extractURL(from: text) {
                        self.saveSharedItem(url: urlString, title: title, tags: inputText)
                    }
                    self.openMainApp()
                }
                return
            }
        }

        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    private func saveSharedItem(url: String, title: String, tags: String?) {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        var items = userDefaults?.array(forKey: "sharedItems") as? [[String: String]] ?? []
        
        if items.contains(where: { $0["url"] == url }) {
            return 
        }
        
        let newItem: [String: String] = [
            "url": url,
            "title": title.isEmpty ? "No Title" : title, 
            "tags": tags ?? ""
        ]
        
        items.append(newItem)
        userDefaults?.set(items, forKey: "sharedItems")
    }

    override func configurationItems() -> [Any]! {
        let tagItem = SLComposeSheetConfigurationItem()
        tagItem?.title = NSLocalizedString("share_tags_title", comment: "")
        tagItem?.value = tagText?.isEmpty == false ? tagText : NSLocalizedString("enter_tags_title", comment: "")

        tagItem?.tapHandler = {
            let alert = UIAlertController(
                title: NSLocalizedString("enter_tags_title", comment: ""),
                message: NSLocalizedString("enter_tags_message", comment: ""),
                preferredStyle: .alert
            )
            alert.addTextField { textField in
                textField.placeholder = NSLocalizedString("tag_placeholder", comment: "")
                textField.text = self.tagText
            }
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { _ in
                let input = alert.textFields?.first?.text ?? ""
                let tags = input
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                let limitedTags = Array(tags.prefix(3))
                self.tagText = limitedTags.joined(separator: ", ")
                tagItem?.value = self.tagText
                self.reloadConfigurationItems()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        return [tagItem!]
    }

    private func openMainApp() {
        let url = URL(string: "tagify://shared")!
        var responder: UIResponder? = self

        while responder != nil {
            if let application = responder as? UIApplication {
                application.performSelector(onMainThread: NSSelectorFromString("openURL:"), with: url, waitUntilDone: false)
                break
            }
            responder = responder?.next
        }

        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}