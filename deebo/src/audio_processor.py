from pydub import AudioSegment
from audio_transcription import Transcriber


class Song:
    def __init__(self, audio) -> None:
        self.audio = audio
        self.audio_segment = self.create_audio_segment()
        self.transcriber = Transcriber(self.audio)

    def to_milliseconds(self, time: int):
        return time * 1000

    def create_audio_segment(self):
        components = self.audio.split(".")

        filetype = components[-1]

        segment = AudioSegment.from_file(self.audio, filetype)

        return segment

    def silence_word(self, word: str):
        times = self.transcriber.get_word_times(word)

        new_segment = self.audio_segment

        for start, end in times:
            start = self.to_milliseconds(start)
            end = self.to_milliseconds(end)

            part1 = new_segment[:start]
            censored_part = AudioSegment.silent(duration=end - start)
            part3 = new_segment[end:]

            new_segment = part1 + censored_part + part3

        return new_segment

    def export_song(self, song, outfile="temp.mp3", format="mp3"):
        file_handle = song.export(outfile, format)

        return file_handle

if __name__ == "__main__":
    t = Transcriber(
        "deebo/data/jay-z-kanye-west-ni-as-in-paris-explicit-128-ytshorts.savetube.me.m4a"
    )
    
    print(t.get_word_dictionary())
