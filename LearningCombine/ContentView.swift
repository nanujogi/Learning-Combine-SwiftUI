//
//  ContentView.swift
//  LearningCombine
//  Created by Nanu Jogi on 03/07/19.

import SwiftUI
import Combine

struct ContentView : View {

    @ObjectBinding var store: GetPetitions
    
    var body: some View {
        Group {
            NavigationView {
                List (store.models) { getp in
                    NavigationLink(destination: Details(modelDetail: getp)) {
                        PetitionRow(p: getp)
                    }
                }
                .navigationBarTitle(Text("Petitions"))
                } // end of NavigationView
            
            } // end of Group

            .onAppear(perform: {
                self.store.fetch() }) // here we use fetch()

    } // end of View
}

struct PetitionRow: View {
    
    var p: Petition
    
    var body: some View {
        VStack (alignment: .leading) {

            Text(p.title)

            Text(p.body)
                .font(.subheadline)
                .color(Color.gray)
                .lineLimit(2)

            Text(p.url)
                .font(.system(size: 9))
                .foregroundColor(Color.blue)
                .lineLimit(nil)

        }
    }
}
