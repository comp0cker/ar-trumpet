import Foundation
import AVFoundation

// All enharmonics are written as note flat
enum Pitch: Int {
    case C = 0
    case Db = 1
    case D = 2
    case Eb = 3
    case E = 4
    case F = 5
    case Gb = 6
    case G = 7
    case Ab = 8
    case A = 9
    case Bb = 10
    case B = 11
}

/**
    Intervals are defined corresponding to the harmonics on a trumpet. In the open position, the following ints produce the following tones:
    0: C4
    1: G4
    2: C5
    3: E5
    4: G5
    5: Bb5
    6: C6
    7: D6
    8: E6
    9: Gb6
    10: G6
*/

class Note {
    var pitch: Pitch = .C
    var octave: Int = 5
    
    var noteMidSound: AVAudioPlayer?
    
    /**
        Each note is defined as 3 mp3 files in the Resources directory. For the note C4, these are defined as follows:
        
        C4_start.mp3
        C4_mid.mp3
        C4_end.mp3
     
        The start mp3 is played immediately on button press. The mid mp3 is looped indefinitely until the button is released, which initiates the end mp3.
     */
    
    init(valveOnePressed: Bool, valveTwoPressed: Bool, valveThreePressed: Bool, interval: Int) {
        if interval < 2 {
            octave = 4
        }
        else if interval > 5 {
            octave = 6
        }
        
        if interval == 1 || interval == 4 || interval == 10 {
            pitch = .G
        }
        else if interval == 3 || interval == 8 {
            pitch = .E
        }
        else if interval == 5 {
            pitch = .Bb
        }
        else if interval == 9 {
            pitch = .Gb
        }
        
        pitchShift(pitchShift: valvesToPitchShift(valveOnePressed: valveOnePressed, valveTwoPressed: valveTwoPressed, valveThreePressed: valveThreePressed))
    }
    
    func playStart() {
        let fileName = "\(pitch)\(octave)_start.mp3"
        play(fileName: fileName)
    }
    
    func playMid() {
        let fileName = "\(pitch)\(octave).mp3"
        let path = Bundle.main.path(forResource: "\(fileName)", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            noteMidSound = try AVAudioPlayer(contentsOf: url)
            noteMidSound?.numberOfLoops = -1
            noteMidSound?.play()
        } catch {
            // couldn't load file :(
        }
    }
    
    func stopMid() {
        noteMidSound?.stop()
    }
    
    func playEnd() {
        let fileName = "\(pitch)\(octave)_end.mp3"
        play(fileName: fileName)
    }
    
    func play(fileName: String) {
        var noteSound: AVAudioPlayer?
        let path = Bundle.main.path(forResource: "\(fileName)", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            noteSound = try AVAudioPlayer(contentsOf: url)
            noteSound?.play()
        } catch {
            // couldn't load file :(
        }
    }
    
    func pitchShift(pitchShift: Int) {
        if pitch.rawValue - pitchShift < 0 {
            pitch = Pitch(rawValue: 12 + pitch.rawValue - pitchShift)!
            octave -= 1
        }
        else {
            pitch = Pitch(rawValue: pitch.rawValue - pitchShift)!
        }
    }
    
    func valvesToPitchShift(valveOnePressed: Bool, valveTwoPressed: Bool, valveThreePressed: Bool) -> Int {
        var pitchShift: Int = 0
        
        if valveTwoPressed {
            pitchShift -= 1
        }
        if valveOnePressed {
            pitchShift -= 2
        }
        if valveOnePressed {
            pitchShift -= 3
        }
        return pitchShift
    }
}
