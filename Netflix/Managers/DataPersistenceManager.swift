//
//  DataPersistenceManager.swift
//  Netflix
//
//  Created by Umut Can on 22.08.2022.
//

import Foundation
import UIKit
import CoreData

class DataPersistenceManager {
    
    static let shared = DataPersistenceManager()
    
    enum DatabaseError: Error{
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
    }
    
    func downloadTitleWith(model : Title, completion: @escaping (Result<Void, Error>) -> Void){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let context = appDelegate.persistentContainer.viewContext
        let item = TitleItem(context: context)
        
        item.id = Int64(model.id)
        item.media_type = model.media_type
        item.original_name = model.original_name
        item.original_title = model.original_title
        item.poster_path = model.poster_path
        item.overview = model.overview
        item.vote_count = Int64(model.vote_count)
        item.release_date = model.release_date
        item.vote_average = model.vote_average
        
        do{
            try context.save()
            completion(.success(()))
        }catch{
            completion(.failure(DatabaseError.failedToSaveData))
        }
    }
    
    func fetchTitleFromDatabase(completion: @escaping (Result<[TitleItem], Error>) -> Void){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        
        let request: NSFetchRequest<TitleItem>
        request = TitleItem.fetchRequest()
        
        do{
            let results = try context.fetch(request)
            completion(.success(results))
        }catch{
            completion(.failure(DatabaseError.failedToFetchData))
        }
    }
    
    func deleteDataFromDatabase(model: TitleItem, completion: @escaping (Result<Void, Error>) -> Void){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(model)
        
        do{
            try context.save()
            completion(.success(()))
        }catch{
            completion(.failure(DatabaseError.failedToDeleteData))
        }
    }
}

