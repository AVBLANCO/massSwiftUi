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
            VStack(spacing: 20) {
                Image(systemName: "figure.walk.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                Text("Planificador de Rutas")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Aquí iría la integración con OpenTripPlanner (/plan) para calcular rutas óptimas de transporte público.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationTitle("Ruta")
        }
    }
}
