//
//  SocialLinkList.swift
//  Routines
//
//  Created by Sam Clemente on 7/31/24.
//

import Foundation

class SocialLinkList: ObservableObject {
    @Published var symbols: [Symbol] = [
        .init(name: "Bluesky", file: "Bluesky", url:"https://bsky.app/profile/stygiantech.dev", color: .blue),
        .init(name: "Routines on GitHub", file: "GitHub", url: "https://github.com/CountableNewt/Routines", color: .primary),
//        .init(name: "Sam on Mastodon", file: "Mastodon", url: "https://indieweb.social/@CountableNewt/", color: .purple),
//        .init(name: "Sam on Bluesky", file: "Bluesky", url: "https://bsky.app/profile/samclemente.me", color: .blue)
//        .init(name: "Threads", file: "Threads", url: "https://www.threads.net/@CountableNewt/", color: .primary),
    ]
}
