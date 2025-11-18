//
//  AvatarGenerator.swift
//  LiteMessenger

import Foundation

enum AvatarGenerator {
    static func initials(for name: String) -> String {
        let components = name.split(separator: " ").map(String.init)
        let initials = components.prefix(2).compactMap { $0.first }.map { String($0) }.joined()
        return initials.isEmpty ? "?" : initials.uppercased()
    }
}
