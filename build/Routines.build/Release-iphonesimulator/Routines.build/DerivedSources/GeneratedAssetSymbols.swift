import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "Amber Icon" asset catalog image resource.
    static let amberIcon = DeveloperToolsSupport.ImageResource(name: "Amber Icon", bundle: resourceBundle)

    /// The "Deep Icon" asset catalog image resource.
    static let deepIcon = DeveloperToolsSupport.ImageResource(name: "Deep Icon", bundle: resourceBundle)

    /// The "Forest Icon" asset catalog image resource.
    static let forestIcon = DeveloperToolsSupport.ImageResource(name: "Forest Icon", bundle: resourceBundle)

    /// The "Goldenrod Icon" asset catalog image resource.
    static let goldenrodIcon = DeveloperToolsSupport.ImageResource(name: "Goldenrod Icon", bundle: resourceBundle)

    /// The "Jum Icon" asset catalog image resource.
    static let jumIcon = DeveloperToolsSupport.ImageResource(name: "Jum Icon", bundle: resourceBundle)

    /// The "Red Icon" asset catalog image resource.
    static let redIcon = DeveloperToolsSupport.ImageResource(name: "Red Icon", bundle: resourceBundle)

    /// The "Royal Icon" asset catalog image resource.
    static let royalIcon = DeveloperToolsSupport.ImageResource(name: "Royal Icon", bundle: resourceBundle)

    /// The "Stygian Tech Favicon" asset catalog image resource.
    static let stygianTechFavicon = DeveloperToolsSupport.ImageResource(name: "Stygian Tech Favicon", bundle: resourceBundle)

    /// The "Teal Icon" asset catalog image resource.
    static let tealIcon = DeveloperToolsSupport.ImageResource(name: "Teal Icon", bundle: resourceBundle)

    /// The "Bluesky" asset catalog image resource.
    static let bluesky = DeveloperToolsSupport.ImageResource(name: "Bluesky", bundle: resourceBundle)

    /// The "Github" asset catalog image resource.
    static let github = DeveloperToolsSupport.ImageResource(name: "Github", bundle: resourceBundle)

    /// The "Mastodon" asset catalog image resource.
    static let mastodon = DeveloperToolsSupport.ImageResource(name: "Mastodon", bundle: resourceBundle)

    /// The "Threads" asset catalog image resource.
    static let threads = DeveloperToolsSupport.ImageResource(name: "Threads", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "Amber Icon" asset catalog image.
    static var amberIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .amberIcon)
#else
        .init()
#endif
    }

    /// The "Deep Icon" asset catalog image.
    static var deepIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .deepIcon)
#else
        .init()
#endif
    }

    /// The "Forest Icon" asset catalog image.
    static var forestIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forestIcon)
#else
        .init()
#endif
    }

    /// The "Goldenrod Icon" asset catalog image.
    static var goldenrodIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .goldenrodIcon)
#else
        .init()
#endif
    }

    /// The "Jum Icon" asset catalog image.
    static var jumIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jumIcon)
#else
        .init()
#endif
    }

    /// The "Red Icon" asset catalog image.
    static var redIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .redIcon)
#else
        .init()
#endif
    }

    /// The "Royal Icon" asset catalog image.
    static var royalIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .royalIcon)
#else
        .init()
#endif
    }

    /// The "Stygian Tech Favicon" asset catalog image.
    static var stygianTechFavicon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .stygianTechFavicon)
#else
        .init()
#endif
    }

    /// The "Teal Icon" asset catalog image.
    static var tealIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tealIcon)
#else
        .init()
#endif
    }

    /// The "Bluesky" asset catalog image.
    static var bluesky: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bluesky)
#else
        .init()
#endif
    }

    /// The "Github" asset catalog image.
    static var github: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .github)
#else
        .init()
#endif
    }

    /// The "Mastodon" asset catalog image.
    static var mastodon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mastodon)
#else
        .init()
#endif
    }

    /// The "Threads" asset catalog image.
    static var threads: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .threads)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "Amber Icon" asset catalog image.
    static var amberIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .amberIcon)
#else
        .init()
#endif
    }

    /// The "Deep Icon" asset catalog image.
    static var deepIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .deepIcon)
#else
        .init()
#endif
    }

    /// The "Forest Icon" asset catalog image.
    static var forestIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forestIcon)
#else
        .init()
#endif
    }

    /// The "Goldenrod Icon" asset catalog image.
    static var goldenrodIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .goldenrodIcon)
#else
        .init()
#endif
    }

    /// The "Jum Icon" asset catalog image.
    static var jumIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jumIcon)
#else
        .init()
#endif
    }

    /// The "Red Icon" asset catalog image.
    static var redIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .redIcon)
#else
        .init()
#endif
    }

    /// The "Royal Icon" asset catalog image.
    static var royalIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .royalIcon)
#else
        .init()
#endif
    }

    /// The "Stygian Tech Favicon" asset catalog image.
    static var stygianTechFavicon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .stygianTechFavicon)
#else
        .init()
#endif
    }

    /// The "Teal Icon" asset catalog image.
    static var tealIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tealIcon)
#else
        .init()
#endif
    }

    /// The "Bluesky" asset catalog image.
    static var bluesky: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bluesky)
#else
        .init()
#endif
    }

    /// The "Github" asset catalog image.
    static var github: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .github)
#else
        .init()
#endif
    }

    /// The "Mastodon" asset catalog image.
    static var mastodon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mastodon)
#else
        .init()
#endif
    }

    /// The "Threads" asset catalog image.
    static var threads: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .threads)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

