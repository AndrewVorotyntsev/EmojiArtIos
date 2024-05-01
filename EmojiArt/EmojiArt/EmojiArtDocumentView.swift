//
//  ContentView.swift
//  EmojiArt
//
//  Created by vorotyncev on 12.09.2023.
//

import SwiftUI

struct EmojiArtDocumentView: View {
  @ObservedObject var document: EmojiArtDocument
  
  @State private var chosenPalette: String = ""
  
  @State private var steadyStateZoomScale: CGFloat = 1.0
  @GestureState private var gestureZoomScale: CGFloat = 1.0
  
  @State private var steadyStatePanOffset: CGSize = .zero
  @GestureState private var gesturePanOffset: CGSize = .zero
  
  
  private var zoomScale: CGFloat {
    steadyStateZoomScale * gestureZoomScale
  }
  
  private var panOffset: CGSize {
    (steadyStatePanOffset + gesturePanOffset) * zoomScale
  }
  
  var body: some View {
    VStack {
      HStack {
        //        PaletteChooser(document: document, chosenPalette: $chosenPalette)
        ScrollView(.horizontal) {
          HStack {
            ForEach(EmojiArtDocument.palette.map{String($0)}, id: \.self) {emoji
              in Text(emoji).font(Font.system(size: defaultEmojiSize))
              .onDrag { NSItemProvider(object: emoji as NSString)}}
          }
          HStack {
            ForEach(["Cool", "Best", "Like"], id: \.self) {text
              in Text(text).font(Font.system(size: defaultEmojiSize)).padding()
              .onDrag { NSItemProvider(object: text as NSString)}}
          }
          HStack {
            ForEach(EmojiArtDocument.images, id: \.self) {image
              in Image(image).resizable().frame(width: defaultEmojiSize, height: defaultEmojiSize).padding()
                .onDrag{NSItemProvider(object: image as NSItemProviderWriting)}
            }}
        }
        .padding(.horizontal)
      }
    }
    GeometryReader { geometry in
      ZStack {
        Rectangle().foregroundColor(.yellow)
        Color.white.overlay(OptionalImage(uiImage: self.document.backgroundImage)
          .scaleEffect(self.zoomScale).offset(self.panOffset))
        .onDrop(of: ["public.image", "public.text"], isTargeted: nil) {
          providers, location in
          var location = geometry.convert(location, from: .global)
          location = CGPoint(x: location.x - geometry.size.width/2,
                             y: location.y - geometry.size.height/2)
          return self.drop(providers: providers, at: location)
        }
        if self.isLoading {
          Image(systemName: "hourglass").imageScale(.large).spinning()
        } else {
          ForEach(self.document.emojis.filter { !EmojiArtDocument.images.contains($0.text) })
          { emoji in Text(emoji.text).position(self.position(for: emoji, in: geometry.size))
              .font(Font.system(size: CGFloat(emoji.size)))
              .gesture(self.moveEmoji(emoji))
              .gesture(self.zoomEmoji(emoji))
          }
          ForEach(self.document.emojis.filter { EmojiArtDocument.images.contains($0.text) }) { emoji in Image(emoji.text)
              .resizable()
              .frame(width: CGFloat(emoji.size), height: CGFloat(emoji.size))
              .position(self.position(for: emoji, in: geometry.size))
              .gesture(self.moveEmoji(emoji))
              .gesture(self.zoomEmoji(emoji))
          }
        }
      }.clipped()
        .gesture(self.doubleTapToZoom(in: geometry.size))
      //        .gesture(self.zoomGesture())
      //        .gesture(self.panGesture())
        .onReceive(self.document.$backgroundImage) { image in
          self.zoomToFit(image, in: geometry.size)
        }
        .onDrop(of: ["public.image", "public.text"], isTargeted: nil) {
          
          providers, location in
          var location = geometry.convert(location, from: .global)
          location = CGPoint(x: location.x - geometry.size.width/2,
                             y: location.y - geometry.size.height/2)
          location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
          location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
          return self.drop(providers: providers, at: location)
        }
        .modifier(
          Popup(
            isPresented: document.showingPopup,
            content: {
              RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white)
                .frame(width: 200, height: 400)
                .shadow(radius: 20)
              VStack {
                Text("Choose mode: ").font(Font.system(size: 26))
                Button(action: self.document.restoreImage) {
                  Text("Edit").font(Font.system(size: 20))
                    .frame(width: 100)
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: self.document.createNewImage) {
                  Text("Create").font(Font.system(size: 20))
                    .frame(width: 100)
                }
                .buttonStyle(.borderedProminent)
              }
            }
          )
        )
    }
    Button(action: self.document.createNewImage) {
      Text("Create new image").font(Font.system(size: 20))
        .frame(width: 200)
    }
    .buttonStyle(.borderedProminent)
    .padding()
  }
  
  var isLoading: Bool {
    document.backgroundURL != nil && document.backgroundImage == nil
  }
  
  private func doubleTapToZoom(in size: CGSize) -> some Gesture {
    TapGesture(count: 2).onEnded {
      withAnimation {
        self.zoomToFit(self.document.backgroundImage, in: size)
      }
    }
  }
  
  private func zoomGesture() -> some Gesture {
    MagnificationGesture()
      .updating($gestureZoomScale) {
        latestGestureScale, gestureZoomScale, transaction in gestureZoomScale = latestGestureScale
      }
      .onEnded {finalGestureScale in self.steadyStateZoomScale *= finalGestureScale}
  }
  
  private func panGesture() -> some Gesture {
    DragGesture()
      .updating($gesturePanOffset) {
        latestDragGestureValue, gesturePanOffset, transaction in
        gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
      }
      .onEnded {finalDragGestureValue in
        self.steadyStatePanOffset = self.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)}
  }
  
  private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
    var location = emoji.location
    location = CGPoint(x: location.x * steadyStateZoomScale, y: location.y * steadyStateZoomScale)
    location = CGPoint(x: emoji.location.x + size.width/2, y: emoji.location.y + size.height/2)
    location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
    return location
  }
  
  private func zoomToFit(_ image: UIImage?, in size: CGSize) {
    if let image = image , image.size.width > 0, image.size.height > 0 {
      let hZoom = size.width / image.size.width
      let vZoom = size.height / image.size.height
      self.steadyStatePanOffset = CGSize.zero
      self.steadyStateZoomScale = min(hZoom, vZoom)
    }
  }
  
  private let defaultEmojiSize: CGFloat = 80
  
  private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
    var found = providers.loadFirstObject(ofType: URL.self) { url in
      self.document.backgroundURL = url
    }
    if !found {
      found = providers.loadObjects(ofType: String.self) {
        string in self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
      }
    }
    return found
  }
  
  @GestureState private var gestureEmojiZoomScale: CGFloat = 1.0
  
  private func zoomEmoji(_ emoji: EmojiArt.Emoji) -> some Gesture {
    MagnificationGesture()
      .onEnded {finalDragGestureValue in
        self.document.scaleEmoji(emoji, by: finalDragGestureValue)
      }
  }
  
  private func moveEmoji (_ emoji: EmojiArt.Emoji) -> some Gesture {
    DragGesture()
      .onEnded { value in
        self.document.moveEmoji(emoji, by: value.translation)
      }
  }
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
