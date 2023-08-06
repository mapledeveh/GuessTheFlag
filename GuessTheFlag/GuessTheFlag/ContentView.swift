//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Alex Nguyen on 2023-05-02.
//

import SwiftUI

// custom view
struct FlagImage: View {
    var stringArray: [String]
    var index: Int
    
    var body: some View {
        Image(stringArray[index])
            .renderingMode(.original)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 5)
    }
}

// custom modifier
struct ColourandFont: ViewModifier {
    var fontSize: Font = .largeTitle.bold()
    var fontColour: Color = .red
    
    
    func body(content: Content) -> some View {
        content
            .font(fontSize)
            .foregroundColor(fontColour)
        // large, blue font suitable for prominent titles in a view
    }
}

extension View {
    func titleStyle(size: Font = ColourandFont().fontSize, colour: Color = ColourandFont().fontColour) -> some View {
        modifier(ColourandFont(fontSize: size, fontColour: colour))
    }
}


struct ContentView: View {
    
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var score = 0
    @State private var remainingQuestions = 8
    @State private var countries = [ "Canada", "Estonia", "France", "Germany", "Ireland", "Nigeria", "Poland", "Russia", "Spain", "UK", "US" ].shuffled()
    let flagEmojis = [ "Canada": "🇨🇦", "Estonia": "🇪🇪", "France": "🇫🇷", "Germany": "🇩🇪", "Ireland": "🇮🇪", "Nigeria": "🇳🇬", "Poland": "🇵🇱", "Russia": "🇷🇺", "Spain": "🇪🇸", "UK": "🇬🇧", "US": "🇺🇸" ]
    
    let labels = [
        "Estonia": "Flag with three horizontal stripes of equal size. Top stripe blue, middle stripe black, bottom stripe white",
        "France": "Flag with three vertical stripes of equal size. Left stripe blue, middle stripe white, right stripe red",
        "Germany": "Flag with three horizontal stripes of equal size. Top stripe black, middle stripe red, bottom stripe gold",
        "Ireland": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe orange",
        "Italy": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe red",
        "Nigeria": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe green",
        "Poland": "Flag with two horizontal stripes of equal size. Top stripe white, bottom stripe red",
        "Russia": "Flag with three horizontal stripes of equal size. Top stripe white, middle stripe blue, bottom stripe red",
        "Spain": "Flag with three horizontal stripes. Top thin stripe red, middle thick stripe gold with a crest on the left, bottom thin stripe red",
        "UK": "Flag with overlapping red and white crosses, both straight and diagonally, on a blue background",
        "US": "Flag with red and white stripes of equal size, with white stars on a blue background in the top-left corner"
    ]

    @State private var correctAnswer = Int.random(in: 0...2)
    
    @State private var buttonTapped = false
    @State private var spinningDegree = 0.0
    @State private var unChosenDegree = 0.0
    @State private var userChoice = 0
    
    func userTapped(_ number: Int) -> Double {
        var faded: Double
        
        if buttonTapped {
            if number == userChoice {
                faded = 1.0
            } else {
                faded = 0.25
            }
        } else {
            faded = 1.0
        }
        return faded
    }
        
    func userIgnored(_ number: Int) -> Double {
        var shrink: Double
        
        if buttonTapped {
            if number == userChoice {
                shrink = 1.0
            } else {
                shrink = 0.75
            }
        } else {
            shrink = 1.0
        }
        return shrink
    }
    
    var body: some View {
        
        ZStack {
            
            RadialGradient(stops: [ .init(color: Color(red: 0.95, green: 0.8, blue: 0.95), location: 0.3),
                                    .init(color: Color(red: 0.7, green: 0.2, blue: 0.35), location: 0.3) ], center: .top, startRadius: 200, endRadius: 700)
            .ignoresSafeArea()
            
            
            VStack {
                Spacer()
                
                Text("Guess The Flag")
                    .titleStyle()
                
                Spacer()
                
                VStack(spacing: 25) {
                    VStack {
                        Text("Tap the flag of")
                            .titleStyle(size: .subheadline.weight(.heavy), colour: .secondary)
                        Text(countries[correctAnswer])
                            .titleStyle(size: .largeTitle.weight(.semibold), colour: .primary)
                    }
                    
                    ForEach(0..<3) { number in
                        Button {
                            // flag was tapped
                            flagTapped(number)
                            withAnimation {
                                spinningDegree += 360
                                unChosenDegree -= 720
                            }
                        } label: {
                            FlagImage(stringArray: countries, index: number)
                                .rotation3DEffect(.degrees(number == userChoice ? spinningDegree : 0), axis: (x: 0, y: 1, z: 0))
                                .rotation3DEffect(.degrees(number != userChoice ? unChosenDegree : 0), axis: (x: 0, y: 1, z: 0))
                                .animation(.interpolatingSpring(stiffness: 50, damping: 10), value: spinningDegree)
                                .opacity(userTapped(number))
                                .scaleEffect(userIgnored(number))
                                .accessibilityLabel(labels[countries[number]] ?? "Unknown Flag")
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                
                Spacer()
                
                Text("Score: \(score)")
                    .titleStyle(size: .title.bold(), colour: .white)
                Text("Questions remain: \(remainingQuestions)")
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            if remainingQuestions > 0 {
                Button("Continue", action: askQuestion)
            } else {
                Button("Restart", role: .destructive, action: restartGame)
            }
            Button("Cancel", role: .cancel, action: {})
                .disabled(true)
        } message: {
            Text("Your \(remainingQuestions > 0 ? "current" : "final") score is: \(score)")
        }
    }
    
    func flagTapped(_ number: Int) {
        if remainingQuestions > 0 {
            if number == correctAnswer {
                scoreTitle = "Correct! \n\(flagEmojis[countries[correctAnswer]]!) is the flag of \(countries[correctAnswer])"
                score += 1
            } else {
                scoreTitle = "Wrong! \(flagEmojis[countries[number]]!) is the flag of \(countries[number])"
            }
        } else {
            restartGame()
        }
        
        userChoice = number
                
        showingScore = true
        remainingQuestions -= 1
        
        buttonTapped = true
    }
    
    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        buttonTapped = false
    }
    
    func restartGame() {        score = 0
        remainingQuestions = 8
        askQuestion()
        
        buttonTapped = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
