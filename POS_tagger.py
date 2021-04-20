# Karl August Kaljuste 2021
# This Python code uses NLTK to tokenize and automatically add POS tags to UT Department of English BA theses

# Upon initialising NLTK, all corpora were downloaded to make sure everything works
import nltk
import os

# The directory string should be set to the location of the previously cleaned up texts
directory = "C:/Users/Dell/Google Drive/Ylikool/baka_andmed/corpus"

# Each file in the above specified directory is processed
for filename in os.listdir(directory):
    file = open(os.path.join(directory, filename), 'r', encoding="UTF-8")
    # The output directory string should be set to where you want the tagged texts to go
    outputf = os.path.join("C:/Users/Dell/Google Drive/Ylikool/baka_andmed/corpus_tagged", filename)
    parsed = ""
    for text in file:
        tokens = nltk.word_tokenize(text) # Each word in the text is tokenized. This unfortunately also separates possessive endings into separate tokens ' and s
        tagged = nltk.pos_tag(tokens) # Each token is tagged for its part of speech
        parsed += str(tagged) # The tagged tokens are stringified and prepared for output
    with open(outputf, 'w', encoding="UTF-8") as resultf: # The strings are finally written to a TXT file in the previously specified output directory with the same name as the source file
        for texts in parsed:
            resultf.write(texts)
    file.close()
