//  Details.swift

import SwiftUI

struct Details : View {
    
    var modelDetail: Petition
    @State private var showsAlert: Bool = false
    
    var body: some View {
        VStack {
            Text(modelDetail.body)
                .font(.subheadline)
                .foregroundColor(Color.gray)
                .padding()
                .lineLimit(nil)
            Text("Signature Count: \(modelDetail.signatureCount)")
            
            Button("Shows Alert") {
                self.showsAlert.toggle()
            }
            .alert(isPresented: $showsAlert) {
                Alert(title: Text(modelDetail.title), message: Text(modelDetail.body), dismissButton: .default(Text("Exit")))
            
            }
            .background(Color.blue)
            Spacer()
        }
    }
}




