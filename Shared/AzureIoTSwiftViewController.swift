//
//  AzureIoTSwiftViewController.swift
//  AzureIoTSwiftSample
//
//  Created by Dane Walton on 2/14/22.
//

import Foundation
import MQTT
import NIOSSL
import CAzureSDKForCSwift

let sem = DispatchSemaphore(value: 0)
let queue = DispatchQueue(label: "a", qos: .background)

class AzureIoTHubClientSwift: ObservableObject {
    private var sendTelemetry: Bool = false;
    private(set) var isSendingTelemetry: Bool = false;
    @Published private(set) var numSentMessages: Int = 0;
    @Published private(set) var numSentMessagesGood: Int = 0;
    
    private(set) var scopeID: String
    private(set) var registrationID: String
    
    @Published private(set) var isHubConnected: Bool = false
    @Published private(set) var isProvisioned: Bool = false
    
    var provisioningDemoClient: DemoProvisioningClient! = nil
    var hubDemoHubClient: DemoHubClient! = nil
    
    private func telemAckCallback() {
        DispatchQueue.main.async { self.numSentMessagesGood = self.numSentMessagesGood + 1 }
    }
    
    public init(myScopeID: String, myRegistrationID: String)
    {
        self.scopeID = myScopeID
        self.registrationID = myRegistrationID
    }
    
    public func startDPSWorkflow()
    {
        provisioningDemoClient = DemoProvisioningClient(idScope: scopeID, registrationID: registrationID)

        provisioningDemoClient.connectToProvisioning()

        while(!provisioningDemoClient.isProvisioningConnected) {}

        provisioningDemoClient.subscribeToAzureDeviceProvisioningFeature()

        provisioningDemoClient.sendDeviceProvisioningRequest()

        queue.asyncAfter(deadline: .now() + 4)
        {
            self.provisioningDemoClient.sendDeviceProvisioningPollingRequest(operationID: self.provisioningDemoClient.gOperationID)
        }

        while(!provisioningDemoClient.isDeviceProvisioned) {}
        
        isProvisioned = true;

        provisioningDemoClient.disconnectFromProvisioning()
    }
    
    public func startIoTHubWorkflow()
    {
        hubDemoHubClient = DemoHubClient(iothub: provisioningDemoClient.assignedHub, deviceId: provisioningDemoClient.assignedDeviceID, telemCallback: telemAckCallback)

        hubDemoHubClient.connectToIoTHub()
        
        self.isHubConnected = true

        while(!hubDemoHubClient.sendTelemetry) {}

        hubDemoHubClient.subscribeToAzureIoTHubFeatures()
    }
    
    public func sendTelemetryMessage()
    {
        self.hubDemoHubClient.sendMessage()
        DispatchQueue.main.async { self.numSentMessages = self.numSentMessages + 1 }
    }
}
