//
//  AnimatableSystemFontModifier.swift
//  EmojiArt
//
//  Created by vorotyncev on 24.10.2023.
//

import SwiftUI

struct AnimatableSystemFontModifier: AnimatableModifier {
    var size: CGFloat
    var weight: Font.Weight = .regular
    var design: Font.Design = .default
    
    func body(content: Content) -> some View {
        content.font(Font.system(size: size, weight: weight, design: design))
    }
    
    var animatableData: CGFloat {
        get {size}
        set {size = newValue}
    }
}
