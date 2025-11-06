//
//  MainTabView.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 6/11/25.
//

import SwiftUI

struct MainTabView: View {
    // El CardViewModel se crea e inyecta aquí.
    // Esta es la capa que mantiene el estado global de la aplicación.
    @StateObject var cardViewModel = CardViewModel()

    var body: some View {
        TabView {
            // 1. Pestaña de Mapa
            MapView()
                .tabItem {
                    Label("Mapa", systemImage: "map.fill")
                }

            // 2. Pestaña de Ruta
            RouteView()
                .tabItem {
                    Label("Ruta", systemImage: "arrow.triangle.turn.up.right.circle.fill")
                }

            // 3. Pestaña de Información
            InfoView()
                .tabItem {
                    Label("Información", systemImage: "creditcard.fill")
                }
        }
        // Inyectamos el ViewModel en el entorno para que InfoView lo acceda
        .environmentObject(cardViewModel)
    }
}
