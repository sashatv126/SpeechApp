//
//  String+Utilities.swift
//

import UIKit

extension String {
    var attributed: NSAttributedString {
        NSAttributedString(string: self, attributes: [.font: UIFont.systemFont(ofSize: 14)])
    }

    func splitToWords() -> [WordModel] {
        var words: [WordModel] = []
        enumerateSubstrings(in: startIndex ..< endIndex, options: .byWords) { substring, range, _, _ in
         if let substring = substring {
               let offset = range.upperBound.distance(in: self)
               words.append(WordModel(text: substring, offset: offset - substring.count))
            }
       }
       return words
  }

    func getDifference(with etalon: String) -> Int {
        count - getIntersection(with: etalon).count
    }

    func getIntersection(with etalon: String) -> [Character] {
        let wordChars = Array(self)
        let etalonChars = Array(etalon)
        return Array(Set(wordChars).intersection(Set(etalonChars)))
    }
}

extension StringProtocol {
    func distance(of element: Element) -> Int? { firstIndex(of: element)?.distance(in: self) }
    func distance<S: StringProtocol>(of string: S) -> Int? { range(of: string)?.lowerBound.distance(in: self) }
}

extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int { string.distance(to: self) }
}

extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

extension String {
    func levenshteinScore(to string: String, ignoreCase: Bool = true, trimWhiteSpacesAndNewLines: Bool = true) -> Float {
        var firstString = self
        var secondString = string

        if ignoreCase {
            firstString = firstString.lowercased()
            secondString = secondString.lowercased()
        }
        if trimWhiteSpacesAndNewLines {
            firstString = firstString.trimmingCharacters(in: .whitespacesAndNewlines)
            secondString = secondString.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let empty: [Int] = Array(repeating: 0, count: secondString.count)
        var last: [Int] = Array(0...secondString.count)

        for (i, tLett) in firstString.enumerated() {
            var cur = [i + 1] + empty
            for (j, sLett) in secondString.enumerated() {
                cur[j + 1] = tLett == sLett ? last[j] : Swift.min(last[j], last[j + 1], cur[j]) + 1
            }
            last = cur
        }

        let lowestScore = max(firstString.count, secondString.count)
        if let validDistance = last.last {
            return 1 - (Float(validDistance) / Float(lowestScore))
        }
        return 0.0
    }
}

infix operator =~
func =~ (string: String, otherString: String) -> Bool {
    string.levenshteinScore(to: otherString) >= 0.85
}
