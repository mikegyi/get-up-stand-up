import AVFoundation

final class ReminderSpeaker {
    private let synthesizer = AVSpeechSynthesizer()

    func speakReminder() {
        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: "Get up stand up. Stand up for your health.")
        utterance.rate = 0.45

        synthesizer.speak(utterance)
    }
}
