//
//  TicTacToeView.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 23.03.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI
import HMSSDK

class TicTacToeModel: ObservableObject {
    @Published var board = TicTacToeModel.emptyBoard
    @Published var updating = false
    private let store: HMSSessionStore
    private var observer: NSObjectProtocol?
    private static let storeKey = "ticTacToe"
    private static let emptyBoard = Array(repeating: Array(repeating: "", count: 3), count: 3)
    
    init(store: HMSSessionStore) {
        self.store = store
        setupObserver()
    }
    
    func set(value: String, row: Int, column: Int) {
        var newState = board
        newState[row][column] = value
        updating = true
        store.set(newState, forKey: TicTacToeModel.storeKey, completion: nil)
    }
    
    func reset() {
        store.set(TicTacToeModel.emptyBoard, forKey: TicTacToeModel.storeKey, completion: nil)
    } 
    
    func cleanup() {
        if let observer = observer {
            store.removeObserver(observer)
        }
    }
    
    private func setupObserver() {
        store.observeChanges(forKeys: [TicTacToeModel.storeKey], changeObserver: { [weak self] key, value in
            guard key == TicTacToeModel.storeKey else { return }
            self?.updating = false
            if let value = value as? [[String]] {
                self?.board = value
            } else if value == nil {
                self?.board = TicTacToeModel.emptyBoard
            }
        }) { [weak self] observer, error in
            self?.observer = observer
        }
    }
}

struct TicTacToeView: View {
    @ObservedObject var model: TicTacToeModel
    @State private var isCross: Bool = true
    @Environment(\.presentationMode) var presentationMode
    
    init(model: TicTacToeModel) {
        self.model = model
    }
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    HStack {
                        Text("O").foregroundColor(.black)
                        Toggle("", isOn: $isCross).labelsHidden()
                        Text("X").foregroundColor(.black)
                    }.background(Color.white)
                    VStack(spacing:1) {
                        ForEach(0..<3) { row in
                            HStack(spacing:1) {
                                ForEach(0..<3) { column in
                                    Button(action: {
                                        if model.board[row][column] == "" {
                                            model.set(value: isCross ? "X" : "O", row: row, column: column)
                                        }
                                    }) {
                                        Text(model.board[row][column])
                                            .font(.largeTitle)
                                            .foregroundColor(.black).padding()
                                    }
                                    .frame(width: 80, height: 80)
                                    .background(Color.white)
                                }
                            }
                        }
                    }.background(Color.black)
                }.disabled(model.updating).blur(radius: model.updating ? 3 : 0)
                if model.updating {
                    ActivityIndicator(style: .medium)
                }
            }
            HStack {
                Button("Reset") {
                    model.reset()
                }.padding().background(Color.white)
                Button("Quit Game") {
                    model.cleanup()
                    presentationMode.wrappedValue.dismiss()
                }.padding().background(Color.white)
            }
        }
    }
}

struct ActivityIndicator: UIViewRepresentable {
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let result = UIActivityIndicatorView(style: style)
        result.startAnimating()
        return result
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
    }
}
