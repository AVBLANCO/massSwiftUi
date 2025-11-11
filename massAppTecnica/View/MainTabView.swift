//
//  MainTabView.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 6/11/25.
//

import SwiftUI

struct MainTabView: View {
    // El CardViewModel se crea e inyecta aquí.
    @Environment(\.modelContext) private var modelContext
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
        .accentColor(.maasPrimary)
        .onAppear {
            let unselectedColor = UIColor.white.withAlphaComponent(0.7)
            let appearance = UITabBarAppearance()

            appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: unselectedColor
            ]
            appearance.backgroundColor = UIColor(Color.maasDark)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            cardViewModel.setup(context: modelContext)
        }
        .environmentObject(cardViewModel)
    }
}
