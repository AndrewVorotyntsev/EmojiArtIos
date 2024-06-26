//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by vorotyncev on 12.09.2023.
//

import Foundation

struct EmojiArt: Codable {
  var backgroundURL: URL?
  var emojis = [Emoji]()
  
  var json: Data? {
    return try? JSONEncoder().encode(self)
  }
  
  init? (json: Data?) {
    if json != nil, let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
      self = newEmojiArt
    } else {
      return nil;
    }
  }
  
  init() {}
  
  struct Emoji: Identifiable, Codable, Hashable {
    let text: String
    // 0, 0 у нас будет находится
    // По дефолту : в левом верхнем x вправо y - вниз
    var x: Int
    var y: Int
    var size: Int
    let id: Int
    
    fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
      self.text = text
      self.x = x
      self.y = y
      self.size = size
      self.id = id
    }
  }
  
  private var uniqueEmojiId = 0
  mutating func addEmoji(_ text: String, x: Int, y: Int, size:Int) {
    uniqueEmojiId += 1
    emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
  }
  
}

// TODO: создать темы и редактор тем
