//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by vorotyncev on 12.09.2023.
//

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject {
  static let palette: String = "😀😎🤯👍🤖💡"
  
  static let images: Array<String> = ["three", "snowman"]
  
  @Published private var emojiArt: EmojiArt = EmojiArt()
  
  private static let untitled = "EmojiArtDocument.untitled"
  
  private var autosaveCancellbale: AnyCancellable?
  
  @Published public var showingPopup = true
  
  func restoreImage() {
    emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtDocument.untitled)) ?? EmojiArt()
    print("\(emojiArt.json?.utf8 ?? "nil")")
    autosaveCancellbale = $emojiArt.sink { emojiArt in  UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtDocument.untitled)}
    fetchBackgroundImageData()
    hidePopup()
  }
  
  func createNewImage() {
    UserDefaults.standard.removeObject(forKey: EmojiArtDocument.untitled)
    emojiArt = EmojiArt()
    autosaveCancellbale = $emojiArt.sink { emojiArt in  UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtDocument.untitled)}
    fetchBackgroundImageData()
    hidePopup()
  }
  
  func hidePopup() {
    showingPopup = false
  }
  
  @Published private (set) var backgroundImage: UIImage?
  
  var emojis: [EmojiArt.Emoji] {emojiArt.emojis}
  
  // MARK: - Intent(s)
  
  func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
    emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
  }
  
  func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
    if let index = emojiArt.emojis.firstIndex(matching: emoji) {
      emojiArt.emojis[index].x += Int(offset.width)
      emojiArt.emojis[index].y += Int(offset.height)
      
    }
  }
  
  func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
    if let index = emojiArt.emojis.firstIndex(matching: emoji) {
      emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
      
    }
  }
  
  var backgroundURL: URL? {
    get {
      emojiArt.backgroundURL
    }
    set {
      emojiArt.backgroundURL = newValue?.imageURL
      fetchBackgroundImageData()
    }
  }
  
  private var fecthImageCancellable: AnyCancellable?
  
  private func fetchBackgroundImageData() {
    backgroundImage = nil
    if let url = self.emojiArt.backgroundURL {
      fecthImageCancellable?.cancel()
      fecthImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
        .map {data, URLResponse in UIImage(data: data)}
        .receive(on: DispatchQueue.main)
        .replaceError(with: nil)
        .assign(to: \EmojiArtDocument.backgroundImage, on: self)
    }
  }
  
}
