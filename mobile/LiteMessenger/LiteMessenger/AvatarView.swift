//
//  AvatarView.swift
//  LiteMessenger


import SwiftUI

struct AvatarView: View {
    let name: String
    let color: Color
    
    var body: some View {
        Text(AvatarGenerator.initials(for: name))
            .fontWeight(.bold)
            .frame(width: 44, height: 44)
            .background(color.gradient, in: Circle())
            .foregroundColor(.white)
    }
}


