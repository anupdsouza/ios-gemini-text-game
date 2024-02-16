//
//  ContentView.swift
//  GeminiMurderMystery
//
//  Created by Anup D'Souza on 12/02/24.
//

import SwiftUI
import GoogleGenerativeAI

struct ContentView: View {
    @State private var fetchingStory = false
    @State private var fetchedStory = false
    @State private var showQuestions = false
    @State private var revealCulprit = false
    @State private var gameState: GameState = .start
    @State private var murderMystery: MurderMystery?
    private let forwardBtnImage = "arrow.forward.circle.fill"
    
    private let prompt = "Create a murder mystery short story surrounding the death of a family patriarch. The family should consist of 5 people including the patriarch. The suspects are the 4 surviving members present at the scene of whom one is the culprit. Each member has a motive for murder. You are the detective in this story investigating the murder. When creating the plot, include clues found at the scene of the crime. Create 4 questions to investigate the identity of the culprit. Each question should be about the suspects with 3 possible responses & a clue. The response to the last question should always be the names of the surviving family members as individual responses. Reply with the details in JSON format with valid fields: plot as string, questions as an array of question objects where each question object is composed of the question as string, clue as string and responses as an array of strings, and finally the culprit as string. Do not use markdown."
    
    private let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
    
    var body: some View {
        VStack {
            switch gameState {
            case .start:
                startView()
            case .story:
                storyView()
            case .questioning:
                questionView()
            case .result:
                resultView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.white)
        .shadow(color: .black, radius: 2, x: 1, y: 1)
        .background {
            Color.clear.overlay {
                Image(gameState.image())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .animation(.easeIn(duration: 0.5), value: gameState.image())
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    @ViewBuilder private func startView() -> some View {
        VStack {
            
            Text("A\nMurder\nMystery")
                .font(.system(size: 90))
            
            Button(action: {
                if fetchedStory {
                    gameState = .story
                } else {
                    if fetchingStory == false {
                        Task {
                            await fetchStory()
                        }
                    }
                }
            }, label: {
                Text(fetchedStory ? "Start Game" : fetchingStory ? "Loading..." : "Fetch Story")
                    .foregroundStyle(.black)
                    .frame(width: 200)
            })
            .buttonStyle(.borderedProminent)
            .tint(.white)
        }
        .onAppear {
            Task {
                await fetchStory()
            }
        }
    }
    
    private func fetchStory() async {
        
        fetchingStory = true
        fetchedStory = false
        
        do {
            let response = try await model.generateContent(prompt)
            guard let text = response.text,
                  let data = text.data(using: .utf8) else  {
                fetchingStory = false
                return
            }
            
            murderMystery = try JSONDecoder().decode(MurderMystery.self, from: data)
            
            await MainActor.run {
                withAnimation {
                    fetchedStory = true
                }
            }
        }
        catch {
            fetchingStory = false
            print(error.localizedDescription)
        }
    }
    
    @ViewBuilder private func storyView() -> some View {
        VStack {
            if let plot = murderMystery?.plot {
                
                plotView(plot)
                
                Button(action: {
                    gameState = .questioning
                }, label: {
                    imageButton(forwardBtnImage)
                })
                .opacity(showQuestions ? 1 : 0)
                .animation(.linear, value: showQuestions)
            }
        }
    }
    
    @ViewBuilder private func plotView(_ text: String) -> some View {
        TypewriterView(text: text)
            .font(.title2)
            .padding()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(text.count) * 0.05) {
                    showQuestions = true
                }
            }
    }
    
    @ViewBuilder private func imageButton(_ imageName: String) -> some View {
        Image(systemName: imageName)
            .font(.largeTitle)
    }
    
    @ViewBuilder private func questionView() -> some View {
        VStack {
            
            Text("Investigation")
            Text("(Select a response for each question)")
            
            if let murderMystery = murderMystery {
                List {
                    ForEach(murderMystery.questions.indices, id: \.self) { index in
                        Section {
                            ForEach(murderMystery.questions[index].responses.indices, id: \.self) { responseIndex in
                                Button(action: {
                                    selectResponse(at: responseIndex, for: index)
                                }) {
                                    HStack {
                                        Text(murderMystery.questions[index].responses[responseIndex])
                                        Spacer()
                                        if murderMystery.questions[index].responses[responseIndex] == 
                                            murderMystery.questions[index].selectedResponse  {
                                            imageButton("checkmark")
                                        }
                                    }
                                }
                            }
                            
                        } header: {
                            
                            Text(murderMystery.questions[index].question)
                            
                        } footer: {
                            
                            Text("Clue: " + murderMystery.questions[index].clue)
                                .font(.subheadline)
                                .padding(.bottom, 20)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.never)
                .background(Color.clear)
                
                Button(action: {
                    gameState = .result
                }) {
                    imageButton(forwardBtnImage)
                }
            }
        }
        .font(.title2)
    }
    
    @ViewBuilder private func resultView() -> some View {
        VStack {
            Text("The killer is...")
            
            Group {
                Text(murderMystery!.culprit)
                    .font(.system(size: 60))
                
                Text(gameResult() ? "Well done !" : "Better luck next time !")
                    .foregroundStyle(gameResult() ? .green : .red)
            }
            .opacity(revealCulprit ? 1 : 0)
            .animation(.easeIn.delay(0.5), value: revealCulprit)
            
            
            HStack(content: {
                Text("Play Again")
                Button(action: {
                    gameState = .start
                }, label: {
                    imageButton(forwardBtnImage)
                })
            })
            .opacity(revealCulprit ? 1 : 0)
            .animation(.easeIn.delay(1), value: revealCulprit)
        }
        .font(.title)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    revealCulprit = true
                }
            }
        }
        .onDisappear {
            revealCulprit = false
        }
    }
    
    private func selectResponse(at responseIndex: Int, for questionIndex: Int) {
        murderMystery?.questions[questionIndex].selectedResponse = 
        murderMystery?.questions[questionIndex].responses[responseIndex]
    }
    
    private func gameResult() -> Bool {
        if let userSelection = murderMystery?.questions.last?.selectedResponse,
           let culprit = murderMystery?.culprit {
            return userSelection.contains(culprit)
        }
        return false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
