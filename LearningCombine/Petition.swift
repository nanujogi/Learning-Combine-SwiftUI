//
//  Petition.swift
//  WhiteHousePetitions
//
//  Created by Nanu Jogi on 27/06/19.
//  Copyright © 2019 Greenleaf Software. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct Petition: Codable, Identifiable {
    var id: String
    var title: String
    var body: String
    var signatureCount: Int
    var url: String
}

