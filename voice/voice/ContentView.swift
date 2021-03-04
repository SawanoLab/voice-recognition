//
//  ContentView.swift
//  voice
//
//  Created by k18046kk on 2021/02/04.
//

import SwiftUI
import Speech

struct ContentView: View {
    @State var recognizedText: String?
    @State var message: String = ""
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))

    var body: some View {
        VStack(alignment: .trailing) {
            Text(recognizedText ?? "")
                .font(.body)
                .frame(width: 480, height: 320, alignment: .top)
                .border(Color.gray)
                .padding()
            HStack {
                Text(message)
                Button("Choose file") {
                    SFSpeechRecognizer.requestAuthorization { (status) in
                        guard status == .authorized else {
                            print("音声入力が認可されていません")
                            return
                        }
                        // NSOpenPanelはMain Threadからのみアクセス可
                        DispatchQueue.main.async {
                            let panel = NSOpenPanel()
                            //panel.title = "音声ファイルを選択してください"
                            panel.allowsMultipleSelection = true // ファイルの複数選択に対応させるためのフラグ
                            let result = panel.runModal()
                            guard result == .OK, let url = panel.url else {
                                print("ファイル読み込みに失敗")
                                return
                            }

                            let speechRequest = SFSpeechURLRecognitionRequest(url: url)
                            self.message = "音声認識中..."
                            self.recognizedText = ""
                            _ = self.speechRecognizer?.recognitionTask(with: speechRequest, resultHandler: { (speechResult, error) in
                                guard let speechResult = speechResult else {
                                    return
                                }

                                if speechResult.isFinal {
                                    self.message = "音声認識が完了しました"
                                    print("Speech in the file is \(speechResult.bestTranscription.formattedString)")
                                } else {
                                    let text = speechResult.bestTranscription.formattedString
                                    self.recognizedText = text
                                }
                            })
                        }
                    }
                }
            }.padding()
        }
    }
}
