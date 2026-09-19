#if canImport(AppKit)
import AppKit
enum Platform {
    static let itemSize: CGFloat = 32
    static let fontSize: CGFloat = 14
}
#else
import UIKit
enum Platform {
    static let itemSize: CGFloat = 44
    static let fontSize: CGFloat = 17
}
#endif
