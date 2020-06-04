import Flutter
import UIKit
import MSAL

class MsalLogin : NSObject, FlutterPlugin  {
    
    // static var result:MSALResult?
    // static var accountError:String = "";
    static var kAuthority:String = "https://login.microsoftonline.com/xxxxxxx/oauth2/authorize"
    static var kScopes: [String] = ["https://graph.microsoft.com/user.read", "https://graph.microsoft.com/Calendars.ReadWrite"]
    
    initialize(kAuthority: String, kScopes: [String], result: @escaping FlutterResult) {
        MsalLogin.kAuthorityI = kAuthority
        MsalLogin.kScopes = kScopes
        initMSAL(result:result)
        result(result)
    }

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "msal_login", binaryMessenger: registrar.messenger())
        let instance = MsalLogin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

   func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    //get the arguments as a dictionary
        let dict = call.arguments! as! NSDictionary
        let kScopes = dict["kScopes"] as? [String] ?? [String]()
        let kAuthority = dict["kAuthority"] as? String ?? ""

        switch( call.method ){
            case "initialize": initialize(kAuthority: kAuthority, kScopes: kScopes, result: result)
            case "getToken": getToken(result: result)
            case "logout": logout(result: result)
            default: result(FlutterError(code:"INVALID_METHOD", message: "The method called is invalid", details: nil))
        } 
    }

    func initMSAL(result: @escaping FlutterResult) throws {
        
        guard let authorityURL = URL(String: kAuthority) else {
            //result(FlutterError(code: "AUTH_ERROR", message: "Unable to create authority URL"))
            return
        }
        
        let authority = try MSALAADAuthority(url: authorityURL)
        
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: kClientID, redirectUri: nil, authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        self.webViewParamaters = MSALWebviewParameters(parentViewController: self)
        result(true);
    }
    
    func getToken(result: @escaping FlutterResult) {
        guard let currentAccount = self.currentAccount() else {
            // We check to see if we have a current logged in account.
            // If we don't, then we need to sign someone in.
            acquireTokenInteractively(result: result)
            return
        }
           
        self.acquireTokenSilently(currentAccount, result: result)
    }
    
    func acquireTokenInteractively(result: @escaping FlutterResult) {
        
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }
        
        let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount
        applicationContext.acquireToken(with: parameters) { (resultMsal, error) in
            if let error = error {
           // result(FlutterError(code: "AUTH_ERROR", message: "Authentication error", details: error!.localizedDescription))
                return "acquireToken -> Could not acquire token: \(error)"
            }
            
            guard let resultMsal = resultMsal else {
             //result(FlutterError(code: "AUTH_ERROR", message: "Authentication error", details: error!.localizedDescription))
                return "Could not acquire token: No result returned"
            }
            result(resultMsal.accessToken)
            //return result.accessToken
        }
    }
    
    func acquireTokenSilently(_ account : MSALAccount!, result: @escaping FlutterResult) {
        
        guard let applicationContext = self.applicationContext else { return }
        let parameters = MSALSilentTokenParameters(scopes: kScopes, account: account)
        
        applicationContext.acquireTokenSilent(with: parameters) { (resultMsal, error) in
            if let error = error {
                let nsError = error as NSError
                if (nsError.domain == MSALErrorDomain) {
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively()
                        }
                        return
                    }
                }
                print("Could not acquire token silently: \(error!.localizedDescription)")
                //result(FlutterError(code: "AUTH_ERROR", message: "Could not acquire token silently:", details: error!.localizedDescription))
            }
            
            guard let resultMsal = resultMsal else {
                return  "Could not acquire token: No result returned"
            }
            result(resultMsal.accessToken)
        }
    }
    
    func currentAccount(result: @escaping FlutterResult) -> MSALAccount? {
        
        guard let applicationContext = self.applicationContext else { return nil }
        do {
            let cachedAccounts = try applicationContext.allAccounts()
            if !cachedAccounts.isEmpty {
                return cachedAccounts.first
            }
        } catch let error as NSError {
           print("Didn't find any accounts in cache: \(error)")
        }
        return nil
    }
    
    /**
     This button will invoke the signout APIs to clear the token cache.
     */
    func signout(completion:@escaping(_ OK:Bool, result: @escaping FlutterResult) -> Void){
        do {
            try initMSAL()
            guard let applicationContext = self.applicationContext else { completion(false); return  }
            guard let account = self.currentAccount() else { completion(false); return }
            try applicationContext.remove(account)
            completion(true)
        } catch let error as NSError {
            completion(false)
            result(FlutterError(code: "AUTH_ERROR", message: "Received error signing account out:", details: error!.localizedDescription))
            accountError = 
        }
    }
    
    // Setup
    func setup() {
        MSALGlobalConfig.loggerConfig.setLogCallback {
            (level: MSALLogLevel, message: String?, containsPII: Bool) in
            if let displayableMessage = message {
                if (!containsPII) {
                    #if DEBUG
                    print(displayableMessage)
                    #endif
                }
            }
        }
    }
}