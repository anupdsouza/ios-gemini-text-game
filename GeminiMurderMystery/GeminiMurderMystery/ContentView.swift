//
//  ContentView.swift
//  GeminiMurderMystery
//
//  Created by Anup D'Souza on 12/02/24.
//

import SwiftUI

struct ContentView: View {
    @State var imageName = "manor"

    var body: some View {
        ZStack {
            VStack {
                Text("A\nMurder\nMystery")
                    .font(.system(size: 90))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 2, x: 1, y: 5)
                Button {
                    
                } label: {
                    Text("START")
                        .font(.title2).bold()
                        .shadow(radius: 2)
                        .padding(.horizontal, 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)

            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .animation(.easeIn(duration: 0.5), value: imageName)
        }
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
