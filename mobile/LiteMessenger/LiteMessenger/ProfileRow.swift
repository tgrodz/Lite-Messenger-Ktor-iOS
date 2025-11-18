//
//  ProfileRow.swift
//  LiteMessenger


import SwiftUI

struct ProfileRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .frame(width: 30, height: 30)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                .foregroundColor(.indigo)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.caption).foregroundColor(.secondary)
                Text(value).fontWeight(.medium)
            }
            Spacer()
        }
    }
}
