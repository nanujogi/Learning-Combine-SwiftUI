//  Details.swift

import SwiftUI

struct Details : View {
    
    var modelDetail: Petition
    
    var body: some View {
        VStack {
            Text(modelDetail.body)
                .font(.subheadline)
                .foregroundColor(Color.gray)
                .padding()
                .lineLimit(nil)
            Text("Signature Count: \(modelDetail.signatureCount)")
            Spacer()
        }

    }
}

