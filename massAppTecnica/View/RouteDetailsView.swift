//
//  RouteDetailsView.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 11/11/25.
//

import SwiftUI

struct RouteDetailsView: View {
    let route: RouteResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Detalles de la ruta")
                    .font(.titleMedium)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 10)

                // Duración total
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.gray)
                    Text("\(route.startTime) → \(route.endTime)")
                        .foregroundColor(.white)
                    Spacer()
                    Text(route.totalDuration)
                        .fontWeight(.bold)
                        .foregroundColor(.maasPrimary)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.5))

                // Pasos de la Ruta
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(route.steps) { step in
                        RouteStepRow(step: step)
                    }
                }
                .padding(.horizontal)

                Spacer() // Empuja el contenido hacia arriba
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.6))
        .cornerRadius(20)
        .padding(.top, -10)
    }
}

// MARK: - Fila de Paso de Ruta

struct RouteStepRow: View {
    let step: RouteStep

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Icono del paso
            VStack(spacing: 2) {
                Image(systemName: step.iconName)
                    .foregroundColor(step.iconName == "figure.walk" ? .gray : .maasPrimary)

                // Línea de conexión (excepto para el último paso)
                if step.duration != nil {
                    Rectangle()
                        .fill(step.iconName == "figure.walk" ? Color.gray : Color.maasPrimary)
                        .frame(width: 2, height: 40)
                }
            }
            .padding(.top, 5)

            // Contenido del paso
            VStack(alignment: .leading, spacing: 4) {
                Text(step.description)
                    .foregroundColor(.white)
                    .fontWeight(.medium)

                // Detalles adicionales (paradas, costo, etc.)
                ForEach(step.detailLines, id: \.self) { detail in
                    Text(detail)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            // Duración/Tiempo
            if let duration = step.duration {
                VStack(alignment: .trailing) {
                    Text(duration)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    // Espacio para la línea de conexión
                    Spacer()
                }
                .frame(height: 50)
            }
        }
    }
}

