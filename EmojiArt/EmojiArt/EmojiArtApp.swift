//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by vorotyncev on 12.09.2023.
//

import SwiftUI

@main
struct EmojiArtApp: App {
  var body: some Scene {
    WindowGroup {
      EmojiArtDocumentView(document:  EmojiArtDocument())
    }
  }
}
