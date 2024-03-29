import UIKit

enum APIError: Error {
    case invaild
    case fatal
}

class ContentService {
    static let shared = ContentService()

    private init() {}

    func fetchText(numberOfParagraph: Int = 1, completionHandler: ((Result<[String], Error>) -> Void)?) {
        URLSession.shared.dataTask(with: URL(string: "https://baconipsum.com/api/?type=all-meat&paras=\(numberOfParagraph)&start-with-lorem=1")!) { data, _, error in
            guard let data = data, error == nil,
                let paragraphs = try? JSONDecoder().decode([String].self, from: data)
                else {
                    DispatchQueue.main.async {
                        completionHandler?(Result<[String], Error>.failure(error!))
                    }
                    return
                }

            DispatchQueue.main.async {
                completionHandler?(Result<[String], Error>.success(paragraphs))
            }
        }.resume()
    }

    // async await 전
    func fetchImage(width: Int, height: Int, completionHandler: ((Result<UIImage, Error>) -> Void)?) {
        URLSession.shared.dataTask(with: URL(string: "https://baconmockup.com/\(width)/\(height)")!) { data, _, error in
            guard let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    DispatchQueue.main.async {
                        completionHandler?(Result<UIImage, Error>.failure(error!))
                    }
                    return
                }

            DispatchQueue.main.async {
                completionHandler?(Result<UIImage, Error>.success(image))
            }
        }.resume()
    }
    

    
    // async, await 전
    func fetchThumbnail(completion: @escaping (Result<UIImage, APIError>) -> Void) {
        let url = URL(string: "https://baconipsum.com/api/?type=all-meat&paras=\(0)&start-with-lorem=1")!
        
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, response, error) in
            
            if let error = error {
                completion(.failure(.invaild))
            } else if (response as? HTTPURLResponse)?.statusCode != 200 {
                completion(.failure(.fatal))
            } else {
                guard let image = UIImage(data: data!) else {
                    completion(.failure(.fatal))
                    return
                }
                
                completion(.success(image))
            }
        }
        
        task.resume()
    }
    
    // async 적용
    func asyncFetch(width: Int, height: Int) async throws -> UIImage {
        let url = URL(string: "https://baconmockup.com/\(width)/\(height)")!
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw APIError.fatal
        }
        
        let image = UIImage(data: data)
        return image!
    }
}
