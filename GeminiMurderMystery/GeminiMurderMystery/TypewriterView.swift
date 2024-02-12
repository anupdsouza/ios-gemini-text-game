//
//  TypewriterView.swift
//  GeminiMurderMystery
//
//  Created by Anup D'Souza on 12/02/24.
//

import SwiftUI

struct TypewriterView: View {
    var text: String
    var typingDelay: Duration = .milliseconds(50)
    
    @State private var animatedText: AttributedString = ""
    @State private var typingTask: Task<Void, Error>?
    
    var body: some View {
        Text(animatedText)
            .onChange(of: text) { _ in animateText() }
            .onAppear() { animateText() }
    }
    
    private func animateText() {
        typingTask?.cancel()
        
        typingTask = Task {
            let defaultAttributes = AttributeContainer()
            animatedText = AttributedString(text,
                                            attributes: defaultAttributes.foregroundColor(.clear)
            )
            
            var index = animatedText.startIndex
            while index < animatedText.endIndex {
                try Task.checkCancellation()
                
                animatedText[animatedText.startIndex...index]
                    .setAttributes(defaultAttributes)
                
                try await Task.sleep(for: typingDelay)
                
                index = animatedText.index(afterCharacter: index)
            }
        }
    }
}

struct TypewriterView_Previews: PreviewProvider {
    static var previews: some View {
        TypewriterView(text: "Hello")
    }
}
