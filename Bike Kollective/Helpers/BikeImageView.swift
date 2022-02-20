//
//  BikeImageView.swift
//  Bike Kollective
//
//  Created by Born4Film on 2/19/22.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

class BikeImageView: UIImageView {
    var task: URLSessionDataTask!
    let spinner = UIActivityIndicatorView()
    
    func loadImage(from url: URL) {
        image = nil
        
        if let task = task {
            task.cancel()
        }
        
        addSpinner()
        
        if let imgCache = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            spinner.removeFromSuperview()
            image = imgCache
            return
        }
        
        task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, let newImage = UIImage(data: data) else {
                print("couldn't load image from url: \(url)")
                return
            }
            
            imageCache.setObject(newImage, forKey: url.absoluteString as AnyObject)
            
            DispatchQueue.main.async {
                self.spinner.removeFromSuperview()
                self.image = newImage
            }
        }
        
        task.resume()
    }
    
    func addSpinner() {
        addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        spinner.startAnimating()
    }
    
}
