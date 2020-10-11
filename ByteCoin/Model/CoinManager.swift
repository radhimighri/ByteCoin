//
//  CoinData.swift
//  ByteCoin
//
//  Created by Radhi Mighri on 5/25/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//


import Foundation

//By convention, Swift protocols are usually written in the file that has the class/struct which will call the
//delegate methods, i.e. the CoinManager.
protocol CoinManagerDelegate {
    
    //Create the method stubs wihtout implementation in the protocol.
    //It's usually a good idea to also pass along a reference to the current class.
    //e.g. func didUpdatePrice(_ coinManager: CoinManager, price: String, currency: String)
    //Check the Clima module for more info on this.
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    //Create an optional delegate that will have to implement the delegate methods.
    //Which we can notify when we have updated the price.

    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "13A4F6CD-5A7D-4E35-B847-1E751E349569"

    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
        func getCoinPrice(for currency: String)  {
            //use String concatenation to add the selected currency at the end of the baseURL
            let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
            //use optional binding to unwrap the URL that's created from the urlStringring
            if let url = URL(string: urlString) {
                
                //create a new URLSession object with default configuration
                let session = URLSession(configuration: .default)
                
                //Create a new data task for the URLSession
                let task = session.dataTask(with: url) { (data, response, error) in
                    if error != nil {
                        self.delegate?.didFailWithError(error: error!)
                        return
                    }
                    
                    //Format the data we got back as a string to be able to print it
    //                let dataAsString = String(data: data!, encoding: .utf8)
    //                print(dataAsString!)

                    // Turn the json data into a real Swift Object (JSON Parsing)
                    
                    if let safeData = data {
                        if let bitcoinPrice = self.parseJSON(safeData) {
                            
                            //Optional: round the price down to 2 decimal places.
                            let priceString = String(format: "%.2f", bitcoinPrice)
                            
                            //Call the delegate method in the delegate (ViewController) and
                            //pass along the necessary data.
                            self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                        }
                    }
                    
                }
                //Start task to fetch data from Bitcoinaverge's servers
                task.resume()
                
            }
        }
    
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder() // this is the object that can decode JSON
        
        do{
            
            let decodedData =   try decoder.decode(CoinData.self, from: data)
            
            let lastPrice = decodedData.rate
            print(lastPrice)
            return lastPrice
            
        } catch { // catch and print any error
            delegate?.didFailWithError(error: error)
            return nil
        }
        
        
    }
}
