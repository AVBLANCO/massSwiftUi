//
//  RouteView.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 6/11/25.
//

import SwiftUI

struct RouteView: View {
    var body: some View {
        NavigationView {
            // 1. Usamos ZStack para establecer el fondo oscuro
            ZStack {
                Color.maasDark.ignoresSafeArea()

                // 2. Contenido principal centrado
                VStack(spacing: 20) {
                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill") // Icono más relevante
                        .resizable()
                        .frame(width: 80, height: 80)
                        // Usamos el color principal de la aplicación
                        .foregroundColor(.maasPrimary)

                    Text("Planificador de Rutas")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white) // Título en blanco

                    VStack(spacing: 10) {
                        Text("Integración OpenTripPlanner")
                            .font(.titleMedium)
                            .foregroundColor(.maasPrimary)

                        Text("Aquí iría la lógica de búsqueda de origen/destino y la integración con la API OpenTripPlanner (/plan) para calcular rutas óptimas de transporte público en tiempo real.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.6)) // Fondo oscuro para la caja de texto
                    )
                    .padding(.horizontal)

                }
                .padding(.top, -50) // Mueve el contenido ligeramente hacia arriba para centrarlo mejor
            }
            .navigationTitle("Ruta")
            // 3. Establecemos la barra de navegación en estilo oscuro
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
