//
//  Extensions.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 10/10/18.
//

import Foundation

extension Collection {
  /**
   Create a new dictionary from array.
   It uses Element like Value for the dictionary
   and provides a creator for creating a key based on Element
  */
  func toDictionary<Key: Hashable>(createKey: (Element) -> Key) -> [Key: Element] {
    var dictionary = [Key: Element]()

    self.forEach { dictionary[createKey($0)] = $0 }

    return dictionary
  }
}
