//
//  Extensions.swift
//  Clima
//
//  Created by Celso Andre on 02/05/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import Foundation

extension String {
    func isNilOrEmpty() -> Bool {
        return self == nil || self.isEmpty
    }
}
