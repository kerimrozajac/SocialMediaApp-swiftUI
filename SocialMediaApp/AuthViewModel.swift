import SwiftUI
import Alamofire
import Combine
import SwiftyJSON

class AuthViewModel: ObservableObject {
    
    @Published var isLoggedIn = false
    @Published var loggedOut = false
    @Published var user: User?
    @Published var username: String?
    @Published var email: String?
    @Published var error: String?
    @Published var userKey = ""
    @Published var csrfToken = ""
    @Published var errorMessage = ""
    
    
    
    let baseURL: String = "http://127.0.0.1:8000/api/v1/dj-rest-auth/"
    
    func registerUser(username: String, email: String, password1: String, password2: String, completion: @escaping (Bool) -> Void) {
        
        //povlaci CSRFToken prije slanja zahtjeva za registraciju
        fetchCSRFToken {
            success in
            if success {
                self.csrfToken = KeychainService.load(key: "CSRFToken")!
                
                
                let signupURL = "\(self.baseURL)registration/"
                
                let parameters = [
                    "username": username,
                    "email": email,
                    "password1": password1,
                    "password2": password2
                ]
                
                let headers = [
                    "Content-Type": "application/json",
                    "X-CSRFToken": self.csrfToken
                ]
                
                print("CSRF token after header and before request")
                print(self.csrfToken)
                
                Alamofire.request(signupURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                    .validate()
                    .responseJSON { response in
                        switch response.result {
                        case .success:
                            completion(true)
                            // TODO: bukvalno su mi login i register ista funkcija, samo sa razlicitim ulaznim parametrima
                            // TODO: srediti ih da to bude bukvalno samo jedna funkcija
                            // TODO: nema smisla da imam dvije funkcije koje rade istu stvar
                            
                        case .failure(let error):
                            if let data = response.data, let errorBody = String(data: data, encoding: .utf8) {
                                self.errorMessage = errorBody
                            } else {
                                self.errorMessage = error.localizedDescription
                            }
                            print(self.errorMessage)
                            completion(false)
                        }
                    }
            }
        }
    }

    
    //TODO: OVO urediti za error message handling
    /*
    private func extractErrorMessage(whatever) {
     
     sredi error message za svaki moguci scenarij
     
    }
    */
    

    
    func loginUser(username: String, password: String, completion: @escaping (Bool) -> Void) {
        let loginURL = "\(baseURL)login/"
        let parameters = ["username": username, "password": password]
         
        
        fetchCSRFToken {
            success in
            if success {
                self.csrfToken = KeychainService.load(key: "CSRFToken")!
            
                let headers = [
                    "Content-Type": "application/json",
                    "X-CSRFToken": self.csrfToken
                ]
                
                
                Alamofire.request(loginURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                    .validate(statusCode: 200..<300)
                    .responseJSON { response in
                        switch response.result {
                        case .success(let data):
                            
                            
                            if let json = data as? [String: Any], let userKey = json["key"] as? String, let headers = response.response?.allHeaderFields as? [String: String], let csrfToken = headers["Set-Cookie"]?.components(separatedBy: "; ").first(where: { $0.hasPrefix("csrftoken=") })?.components(separatedBy: "=").last  {
                                self.userKey = userKey
                                //print("userKey upon login")
                                //print(self.userKey)
                                
                                self.csrfToken = csrfToken
                                //print("csrfToken upon login")
                                //print(self.csrfToken)
                                
                                let saveResult = (key: KeychainService.save(key: "userKey", data: userKey), csrf: KeychainService.save(key: "CSRFToken", data: csrfToken))
                                self.isLoggedIn = true
                                self.username = username
                                completion(saveResult.key)
                            } else {
                                completion(false)
                            }
                        case .failure(let error):
                            if let data = response.data, let errorBody = String(data: data, encoding: .utf8) {
                                self.errorMessage = errorBody
                            } else {
                                self.errorMessage = error.localizedDescription
                            }

                            completion(false)
                        }
                    }

            }

        }
        
    }
    

    
    func loadUser() {
        // TODO: Implement user logout logic
        let token = self.userKey
        let userURL = "\(baseURL)user/"
        // Make a request to the user info endpoint using Alamofire
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(userURL, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let json):
                    // Store the user data in the view model
                    if let userJSON = json as? [String: Any] {
                        // Create a new User object
                        //let user = User()
                        // Set its properties based on the values in the JSON
                        //user.pk = userJSON["pk"] as? Int ?? 0
                       
                        let username = userJSON["username"] as? String ?? ""
                        let email = userJSON["email"] as? String ?? ""
                        let firstName = userJSON["first_name"] as? String ?? ""
                        let lastName = userJSON["last_name"] as? String ?? ""
                        let user = User(username: username, email: email, firstName: firstName, lastName: lastName)
                        // Store the user data in the view model
                        self.user = user
                    }
                    
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
    
    func logoutUser() {
        let url = URL(string: "http://127.0.0.1:8000/api/v1/dj-rest-auth/logout/")!
        //var logoutMessage = ""
        
        self.csrfToken = KeychainService.load(key: "CSRFToken")!
        self.userKey = KeychainService.load(key: "userKey")!
        
        print("CSRF TOKEN upon logout")
        print(self.csrfToken)
        
        print("Authorization token upon logout")
        print(self.userKey)
        
        let headers = [
            "Content-Type": "application/json",
            "X-CSRFToken": self.csrfToken,
            "Authorization": "Token " + self.userKey
        ]
        
        Alamofire.request(url, method: .post, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let value = response.value {
                if let json = value as? [String: Any], let logoutMessage = json["detail"] as? String {
                    print(logoutMessage)
                }
            }
        }
        
        // Remove the token from the keychain
        let deleteResult = (csfr: KeychainService.delete(key: "CSRFToken"), key: KeychainService.delete(key: "userKey"))
        
        if deleteResult.csfr {
            print("CSRFToken deleted from Keychain")
        }
        
        
        if deleteResult.key {
            print("userKey deleted from Keychain")
        }
        
        
        // Set the isLoggedIn property to false
        self.isLoggedIn = false
        
        // Set the username and email properties to empty string
        self.username = ""
        self.email = ""
        
    }
    

    

    func resetPassword(email: String, completion: @escaping (Bool) -> Void) {
        let resetURL = "\(baseURL)password/reset/"
        let parameters = ["email": email]
        
        fetchCSRFToken {
            success in
            if success {
                self.csrfToken = KeychainService.load(key: "CSRFToken")!
                
                let headers = [
                    "Content-Type": "application/json",
                    "X-CSRFToken": self.csrfToken
                ]
                
                Alamofire.request(resetURL, method: .post, parameters: parameters, headers: headers)
                    .validate()
                    .responseJSON { response in
                        switch response.result {
                        case .success:
                            completion(true)
                        case .failure(let error):
                            self.errorMessage = error.localizedDescription
                            completion(false)
                            print(self.errorMessage)
                        }
                    }
            }
        }
    }


    
    func fetchCSRFToken(completion: @escaping (Bool) -> Void) {
        let csrfURL = "http://127.0.0.1:8000/csrf_token/"
        
        Alamofire.request(csrfURL)
            .response { response in
            if let headers = response.response?.allHeaderFields as? [String: String],
               let csrfToken = headers["Set-Cookie"]?.components(separatedBy: "; ").first(where: { $0.hasPrefix("csrftoken=") })?.components(separatedBy: "=").last {
                let saveResult = KeychainService.save(key: "CSRFToken", data: csrfToken)
                completion(saveResult)
            } else {
                completion(false)
            }
        }
    }
    
    
    
    func changePassword(newPassword: String, completion: @escaping (Bool, Error?) -> Void) {
        // Make the API request to change the password using Alamofire
        
        self.csrfToken = KeychainService.load(key: "CSRFToken")!
        self.userKey = KeychainService.load(key: "userKey")!
        
        let changePasswordURL = "\(self.baseURL)password/change/"
        
        
        let headers = [
            "Content-Type": "application/json",
            "X-CSRFToken": self.csrfToken,
            "Authorization": "Token " + self.userKey
        ]
        
        let parameters: [String: Any] = [
            "new_password1": newPassword,
            "new_password2": newPassword
        ]
        
        Alamofire.request(changePasswordURL, method: .post,  parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            // TODO: responseJSON deprecated and will be removed in Alamofire 6. Use responseDecodable instead
            .responseJSON { response in
                
                //TODO: ovo dole treba popraviti
                //TODO: prvo treba sredit ovaj success da se oslika u UI-u
                //TODO: zatim treba ovaj fail srediti da uopste nesto radi, pa da proslijedi
                //TODO: ovaj error message sto iscupa i izbaci na UI-u kao alert

                
                switch response.result {
                
                // ovaj success case stvarno fino odradi
                // vrati tamo completion true, ono uradi svoj print
                // ovdje izvuce response message i lijepo je isprinta
                case .success:
                    if let json = response.value as? [String: Any] {
                        if let passwordChangeMessage = json["detail"] as? String {
                            print(passwordChangeMessage)
                            completion(true, nil)
                        }
                    }

                    
                case .failure(let error):
                    if let json = response.value as? [String: Any] {
                        if let passwordChangeMessage = json["new_password2"] as? String {
                            print(passwordChangeMessage)
                            completion(false, error)
                        }
                    }

                    // Error occurred during password change
                    
                }
            }
        
        
    }


    
}

enum UserKey: String {
    case key
}

struct LoginResponse: Decodable {
    let key: String
}
