import Foundation
import SwiftUI

enum Data {

    static let applink = URL(string: "https://apps.apple.com/app/id6757550491")!
    static let terms = URL(string: "https://docs.google.com/document/d/e/2PACX-1vRvNb0eoc-ePU75Yb-YBRG5ncN6iKO2Qy7xEbQ-s5kP5ZT11FdqPGDaq5nReuSs8AypSMKJufar59GP/pub")!
    static let policy = URL(string: "https://docs.google.com/document/d/e/2PACX-1vRvNb0eoc-ePU75Yb-YBRG5ncN6iKO2Qy7xEbQ-s5kP5ZT11FdqPGDaq5nReuSs8AypSMKJufar59GP/pub")!

    static var shareMessage: String {
        """
        Discover top casino hotels 🏨 curated stays for every taste. Experience luxury & fun 🎲💎 spas, gaming, and nightlife. Explore local gems 🌿♨️ dining, attractions, and insider tips.
        \(applink.absoluteString)
        """
    }

    static var shareItems: [Any] { [shareMessage, applink] }
}
