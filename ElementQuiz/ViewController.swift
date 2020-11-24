//
//  ViewController.swift
//  ElementQuiz
//
//  Created by Андрей Бородкин on 22.11.2020.
//

import UIKit

enum Mode {
    case flashCard
    case quiz
}

enum State {
    case question
    case answer
    case score
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    let fixedElementList = ["Carbon", "Gold", "Chlorine", "Sodium"]
    var elementList: [String] = []
    var currentElementIndex = 0
    
    func updateFlashCardUI(elementName: String){
        //Text field and keyboard
        textField.isHidden = true
        textField.resignFirstResponder()
        
        //Answer label
        if state == .answer {
            answerLabel.text = elementName
        } else {
            answerLabel.text = "?"
        }
        
        //Segmented control
        modeSelector.selectedSegmentIndex = 0
        
        //Buttons
        showAnswerButton.isHidden = false
        nextButton.isEnabled = true
        nextButton.setTitle("Next Element", for: .normal)
        
    }
    
    func updateQuizUI(elementName: String) {
        //Text field and keyboard
        textField.isHidden = false
        switch state {
        case .question:
            textField.isEnabled = true
            textField.text = ""
            textField.becomeFirstResponder()
        case .answer:
            textField.isEnabled = false
            textField.resignFirstResponder()
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
        }
        //updates app's UI in quiz mode.
        switch state {
        case .question:
            answerLabel.text = ""
        case .answer:
            if answerIsCorrect {
                answerLabel.text = "Correct!"
            } else {
                answerLabel.text = "❌\nCorrect answer: " + elementName
            }
        case .score:
            answerLabel.text = ""
        }
        
        //Score display
        if state == .score {
            displayScoreAlert()
        }
        //Segmented control
        modeSelector.selectedSegmentIndex = 1
        
        //Buttons
        showAnswerButton.isHidden = true
        if currentElementIndex == elementList.count-1{
            nextButton.setTitle("Show Score", for: .normal)
        } else {
            nextButton.setTitle("Next Question", for: .normal)
        }
        
        switch state {
        case .question:
            nextButton.isEnabled = false
        case .answer:
            nextButton.isEnabled = true
        case .score:
            nextButton.isEnabled = false
        }
    }

    func updateUI() {
        // Shared code: updating the image.
        let elementName = elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
        
        // Mode specific UI updates are split into two
        // methods for bett readability.
        switch mode {
        case .flashCard:
            updateFlashCardUI(elementName: elementName)
        case .quiz:
            updateQuizUI(elementName: elementName)
            
        }
    }
    
    var mode: Mode = .flashCard {
        didSet{
            switch mode {
            case .flashCard:
                setupFlashCards()
            case .quiz:
                setupQuiz()
            }
            updateUI()
        }
    }
    var state: State = .question
    
    //QUiz specific state
    var answerIsCorrect = false
    var correctAnswerCount = 0
    
    //Runs after uer hits return button on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // get the text from the text field
        let textFieldContents = textField.text
        
        // determine whether the user answered correctly and update appropriate quiz
        if textFieldContents?.lowercased() == elementList[currentElementIndex].lowercased() {
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            answerIsCorrect = false
        }
        
        // the app should now display the answer to the user
        state = .answer
        updateUI()
        
        
        return true
        
    }
    
    //THis code shows an alert
    func displayScoreAlert(){
        let alert = UIAlertController(title: "Quiz Score", message: "Your score is \(correctAnswerCount) of \(elementList.count).", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: scoreAlertDismissed(_:))
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func scoreAlertDismissed(_ action: UIAlertAction) {
        mode = .flashCard
    }
    
    //setup new flash card session
    func setupFlashCards() {
        elementList = fixedElementList
        state = .question
        currentElementIndex = 0
    }
    
    //setup new quiz session
    func setupQuiz() {
        elementList = fixedElementList.shuffled()
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func showAnswer(_ sender: UIButton) {
        state = .answer
        updateUI()

    }

    
    @IBAction func switchModes(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            mode = .flashCard
        } else {
            mode = .quiz
        }
    }
    @IBAction func next(_ sender: UIButton) {
        currentElementIndex += 1
        if currentElementIndex >= elementList.count{
            currentElementIndex = 0
            if mode == .quiz {
                state = .score
                updateUI()
                return
            }
        }
        state = .question
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mode = .flashCard
    }


}

