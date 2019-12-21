//
//  API.swift
//  Virtual boy
//
//  Created by Fish on 07/12/2019.
//  Copyright © 2019 Fish. All rights reserved.
//

import Foundation

class API {
    
    var apiKey: String = {
        return "5d87d655dbb7a95ea02a4c94f4822d53"
    }()
    
    //return the instance of user api
    public static func getInstance() -> API {
        return SingletonHolder.INSTANCE
    }
    
    func getPhotos(lat: Double, lon: Double, page: Int = 1, completionHandler: @escaping (_ resultUrls: [String]?,_ resultTitles: [String]?,_ pages: Int? ,_ error: Error?)
        -> Void) {
        let request = URLRequest(url: magicUrl(lat: lat, lon: lon, page: page))
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(nil, nil, nil, error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(nil, nil, nil, error)
                return
            }
            
            let parsedResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult?["photos"] as? [String:AnyObject] else {
                completionHandler(nil, nil, nil, error)
                return
            }
            
            /* Guard: Is the "pages" key in our result? */
            guard let pages = photosDictionary["pages"] as? Int else {
                completionHandler(nil, nil, nil, error)
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                completionHandler(nil, nil, nil, error)
                return
            }
            
            var urlArray = [String]()
            var titleArray = [String]()
            
            for photo in photosArray {
                let photoDictionary = photo as [String:Any]
                
                /* GUARD: Does our photo have a key for 'url_q'? */
                guard let imageUrlString = photoDictionary["url_q"] as? String else {
                    completionHandler(nil, nil, nil, error)
                    return
                }
                
                guard let imageTitleString = photoDictionary["title"] as? String else {
                    completionHandler(nil, nil, nil, error)
                    return
                }
                
                urlArray.append(imageUrlString)
                titleArray.append(imageTitleString)
            }
            completionHandler(urlArray, titleArray, pages, nil)
        }
        task.resume()
        
    }
    
    func downloadPhoto(imageURL: String, completionHandler: @escaping(_ imageData: Data?, _ error: Error?) ->  Void) -> URLSessionTask {
        
        let url = URL(string: imageURL)
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) {data, response, error in
            
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(data, nil)
            }
        }
        task.resume()
        return task
    }
    
    private func magicUrl(lat: Double, lon: Double, page: Int) -> URL {
        
        var url = URLComponents()
        url.scheme = "https"
        url.host = "api.flickr.com"
        url.path = "/services/rest"
        url.queryItems = [URLQueryItem]()
        
        let params = [
            "method": "flickr.photos.search",
            "api_key": apiKey,
            "lon": "\(lon)",
            "lat": "\(lat)",
            "safe_search": "1",
            "extras": "url_q",
            "format": "json",
            "nojsoncallback": "1",
            "per_page": "30",
            "page": "\(page)",
        ]
        
        for (key, value) in params {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            url.queryItems!.append(queryItem)
        }
        
        return (url.url)!
    }
    
}

//This class is created make the singleton thread safe
private class SingletonHolder {
    public static let INSTANCE = API()
}
