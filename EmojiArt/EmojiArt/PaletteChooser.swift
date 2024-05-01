////
////  PaletteChooser.swift
////  EmojiArt
////
////  Created by vorotyncev on 05.12.2023.
////
//
//import SwiftUI
//
//struct PaletteChooser: View {
//  @ObservedObject var document: EmojiArtDocument
//  @Binding var chosenPalette: String
//  @State private var showPaletteEditor = false
//  
//  var body: some View {
//    HStack {
//      Stepper(
//        onIncrement: {
//          self.chosenPalette = self.document.palette(after: self.chosenPalette)
//        },
//        onDecrement: {
//          self.chosenPalette = self.document.palette(before: self.chosenPalette)
//        },
//        label: {EmptyView()}
//      )
//      Text(self.document.paletteNames[self.chosenPalette] ?? "nil")
//      Image(systemName: "keyboard").imageScale(.large)
//        .onTapGesture {
//          self.showPaletteEditor = true
//        }
//        .popover(
//          isPresented: @showPaletteEditor) {
//            PaletteEditor()
//          }
//    }
//    .fixedSize(horizontal: true, vertical: false)
//    .onAppear {
//      self.chosenPalette = self.document.defaultPalette
//    }
//  }
//}
//
//
//struct PaletteEditor: view {
//  var body: some View {
//    Text("Palette Editor")
//  }
//}
