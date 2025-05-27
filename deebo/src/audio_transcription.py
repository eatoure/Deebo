from faster_whisper import WhisperModel
from pprint import pprint


class Transcriber:
    """The main class to be interacted with"""

    def __init__(self, audio, model="medium", device="cpu", language= None):
        self.model = WhisperModel(model, device=device, compute_type="int8")
        self.audio = audio
        self.language = language
        self.segments =self.get_transcript()
        self.dictionary = self.get_word_dictionary()

    def get_transcript(self):
        """Returns a transcript of words in the song, with no timestamps"""
        segments, _ = self.model.transcribe(self.audio, self.language, word_timestamps=True)

        return segments

    def normalize_word(self, word: str):
        return word.lower().strip()

    def get_word_dictionary(self):
        """Returns a dictionary structure using all unique words found in the song
        as the key, and their start and end timestamps, alongside the confidence
        value of all appearances of the word in the song"""

        word_dictionary = {}

        for segment in self.segments:
            for word_info in segment.words:
                word = self.normalize_word(word_info.word)
                start = word_info.start
                end = word_info.end
                prob = word_info.probability

                if word not in word_dictionary:
                    word_dictionary[word] = []

                info = {"start": start, "end": end, "probability": prob}
                word_dictionary[word].append(info)

        return word_dictionary

    def get_word_data(self, word: str):
        """Returns the st"""
        word = self.normalize_word(word)
        
        if word in self.dictionary:
            return self.dictionary[word]
        else:
            return None

    def get_word_times(self, word):
        word = self.normalize_word(word)
        
        info = self.get_word_data(word)
        
        if info: 
            timestamps = []

            for appearance in info:
                start_time = appearance["start"]
                end_time = appearance["end"]

                word_period = (start_time, end_time)

                timestamps.append(word_period)

            return timestamps
        else:
            return None


if __name__ == "__main__":
    t = Transcriber(
        audio="/Users/aranyeosakwe/deebo/deebo/data/Melanie Martinez - Play Date (Official Audio).mp3"
    )

    print(t.get_word_times("you"))
