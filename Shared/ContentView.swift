//
//  ContentView.swift
//  Shared
//
//  Created by Dane Walton on 2/14/22.
//

import SwiftUI

struct iotDemoView: View {
    @ObservedObject var myHubClient = AzureIoTHubClientSwift(myScopeID: myScopeID, myRegistrationID: myRegistrationID)
    
    var body: some View {
        VStack {
            Group {
                HStack {
                    Text("Azure SDK for C on iOS")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(/*@START_MENU_TOKEN@*/Color(hue: 0.66, saturation: 0.97, brightness: 0.664)/*@END_MENU_TOKEN@*/)
                        .padding()
                    Spacer()
                }
                Divider()
                authenticationItems(iotClient: myHubClient)
                Divider()
                metricsItems(iotClient: myHubClient)
                Divider()
                Spacer()
            }
        }
    }
}

struct authenticationItems: View {
    @ObservedObject var iotClient: AzureIoTHubClientSwift
    var body: some View {
        HStack {
            Text("Start DPS").padding()
            Spacer()
            Button(action: {
                iotClient.startDPSWorkflow()
            }, label: {
                Text("Run")
            }).padding()
        }
        HStack {
            Text("Provisioning Status").padding()
            Spacer()
            if(iotClient.isProvisioned) {
                Text("Provisioned").foregroundColor(Color.green).padding()
            } else {
                Text("Not Provisioned").foregroundColor(Color.red).padding()
            }
        }
        Divider()
        HStack {
            Text("Connect to IoT Hub").padding()
            Spacer()
            Button(action: {
                iotClient.startIoTHubWorkflow()
            }, label: {
                Text("Connect")
            }).padding()
        }
        HStack {
            Text("Connection Status").padding()
            Spacer()
            if(iotClient.isHubConnected) {
                Text("Connected").foregroundColor(Color.green).padding()
            } else {
                Text("Disconnected").foregroundColor(Color.red).padding()
            }
        }
    }
}

struct metricsItems: View {
    @State private var methodName = "nil"

    @ObservedObject var iotClient: AzureIoTHubClientSwift

    var body: some View {
        HStack {
            Text("Send Telemetry Message").padding()
            Spacer()
            Button(action: {
                iotClient.sendTelemetryMessage()
            }, label: {
                Text("Send")
            }).padding()
        }
        HStack {
            Text("Messages Sent").padding()
            Spacer()
            VStack {
                Text("Sent")
                Text("\(iotClient.numSentMessages)")
            }.padding()
            VStack {
                Text("Confirmed")
                    .foregroundColor(Color.green)
                Text("\(iotClient.numSentMessagesGood)")
            }.padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        iotDemoView()
    }
}
