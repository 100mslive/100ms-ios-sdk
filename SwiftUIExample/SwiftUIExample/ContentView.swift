//
//  ContentView.swift
//  SwiftUIExample
//
//  Created by Pawan Dixit on 16/12/2022.
//

import SwiftUI
import HMSSDK

struct ContentView: View {
    
    @StateObject var videoSDK = VideoSDK.shared
    @State var isJoining = false
    
    var body: some View {
        
        Group {
            if videoSDK.isJoined {
                List {
                    ForEach(videoSDK.peers, id: \.self) { peer in
                        HMSPeerTile(peer: peer)
                            .frame(height: 300)
                    }
                }
            }
            else if isJoining {
                ProgressView()
            }
            else {
                Text("Join")
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .onTapGesture {
                        videoSDK.joinRoom()
                        isJoining.toggle()
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
