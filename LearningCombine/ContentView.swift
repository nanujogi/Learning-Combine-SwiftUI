//
//  ContentView.swift
//  LearningCombine
//  Created by Nanu Jogi on 03/07/19.

import Foundation
import SwiftUI
import Combine

struct ContentView : View {
    
    @ObservedObject var store: GetPetitions
    
    var body: some View {
        Group {
            if store.models.isEmpty {
                LoadingView()
            } else {
                NavigationView {
                    List (store.models) { getp in
                        NavigationLink(destination: Details(modelDetail: getp)) {
                            PetitionRow(p: getp)
                        }
                    }
                    .navigationBarTitle(Text("Petitions"))
                } // end of NavigationView
            }
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
                .lineLimit(1)
            
            Text(p.body)
                .font(.subheadline)
                .foregroundColor(Color.gray)
                .lineLimit(1)
            
            Text(p.url)
                .font(.system(size: 10))
                .foregroundColor(Color.blue)
                .lineLimit(nil)
        }
    }
}

struct LoadingView: UIViewRepresentable {
    typealias UIViewType = UIActivityIndicatorView
    
    func makeUIView(context: UIViewRepresentableContext<LoadingView>) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .medium)
        view.sizeToFit()
        view.startAnimating()
        return view
    }
    
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<LoadingView>) {
        // Todo
    }
}
