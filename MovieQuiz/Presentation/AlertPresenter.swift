//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Артем Шепелев on 16.01.2026.
//

import UIKit

final class AlertPresenter {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        alert.addAction(action)
        viewController?.present(alert, animated: true)
    }
}
