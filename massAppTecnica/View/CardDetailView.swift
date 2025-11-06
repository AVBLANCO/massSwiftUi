//
//  CardDetailView.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 6/11/25.
//

import SwiftUI
import Foundation

/// Vista para mostrar el detalle de una tarjeta seleccionada.
struct CardDetailView: View {
    let card: TullaveCard

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Un título grande para la tarjeta
            Text("Detalles de Tarjeta")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)

            Group {
                // Información principal
                CardDetailItem(label: "Nombre Completo", value: card.fullName, icon: "person.fill")
                Divider()
                CardDetailItem(label: "Serial", value: card.serial, icon: "number.circle.fill")
                Divider()
                CardDetailItem(label: "Perfil", value: card.profile, icon: "id-card.fill")
                Divider()
                CardDetailItem(label: "Fecha de Registro", value: formattedDate(card.registeredDate), icon: "calendar")
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationTitle("Tarjeta \(card.serial)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// Componente auxiliar para CardDetailView
struct CardDetailItem: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
        }
    }
}
