# Karl August Kaljuste 2021
# This R script tries to automatically clean up BA theses from the University of Tartu Department of English Studies.
# It removes excess text not relevant to language analysis and text not written by the students themselves (quotes).
# The script cannot remove long quotations (written in smaller font) and may erroneously delete too much or too little; manually checking each text afterward is required.

# The pdftools package is used to read the PDF files in R.
install.packages("pdftools")
library(pdftools)

# The working directory for this script should contain all the PDF files to be processed.
files <- dir(pattern = ".pdf")

# Each PDF file in the directory is processed separately
for (i in files) {
  text <- pdf_text(pdf = i)
  
  # The script first finds the abstract of the thesis. This will also be kept in the text.
  abstract <- grep('\r\n *abstract\r\n|^abstract\r\n', text, ignore.case = TRUE, value = FALSE)
  
  # The script then determines the location of the introduction of the thesis.
  intro <- grep('^\\s*[0-9]*\\s*introduction', text, ignore.case = TRUE, value = FALSE)
  
  # Removing the title page and table of contents, leaving the abstract untouched.
  if (abstract < 3) {
    clean <- text[-(1:abstract-1)][-(2)] 
  } else {
    clean <- text[-(1:2)]
  }
  
  # First wave of regular expressions, cleaning up excess whitespace and punctuation left over from PDF to text conversion.
  clean <- gsub(' +'," ",clean)
  clean <- gsub('\t',"",clean)
  clean <- gsub('^ *| *$',"",clean)
  clean <- gsub('^ *| *$|^\n*',"",clean)
  clean <- gsub('\r',"",clean)
  clean <- gsub('^\\s*|^[0-9]\\s*|^[[:punct:]]*\\s*[0-9]*\\s*',"",clean)
  
  # Finding the list of references
  ref <- grep('^references.*|^list of references.*|^the list of references.*|\nlist of references|\nreferences|\nthe list of references', clean, ignore.case = TRUE, value = FALSE)
  
  # In case there is more than one mention of references found, I use the last value
  ref <- tail(ref, n=1)
  
  # In some cases, the list of references is not titled as such. In that case, I find the "primary sources".
  if (ref<20) {
    ref <- grep('^primary sources', clean, ignore.case = TRUE, value = FALSE)
  }
  
  # Keeping only text up until the list of references.
  # Everything from the list of references onwards is not needed.
  clean <- clean[1:ref-1]
  
  # Second wave of regular expressions, further cleaning up the text
  # First, I mark the ends of sentences.
  clean1 <- gsub('([[:alpha:]][[:alpha:]]+\\.| \\.|[\\)\\"\\”\\“]\\.)',"\\1¤",clean)
  clean1 <- gsub('(\n *[[:upper:]])',"¤\\1",clean1)
  
  # Trying to identify section titles and remove them
  clean1 <- gsub('^[[:upper:]][[:upper:]]+.*?\n',"",clean1)
  
  # Removing line breaks to keep sentences together.
  clean1 <- paste(clean1, collapse="\n")
  
  # Removing more excess whitespace
  clean1 <- gsub('\\s*\\(.*?\\)\\s*',"",clean1)
  
  # Attempting to remove quotes. A bit of a mess, as some quotation marks in the texts are wildly broken. May remove too much or too little!
  clean1 <- gsub('(\\").*?([\\"\\“\\”])|(\\“).*?([\\”\\"])',"\\1\\2\\3\\4",clean1)
  
  # Splitting the text into separate elements (lines) based on earlier attempt at marking sentence endings.
  clean1 <- unlist(strsplit(clean1, split="¤"))
  
  # Removing extra line breaks, replacing them with spaces.
  clean1 <- gsub('\n'," ",clean1)
  
  # Again removing excess whitespace.
  clean1 <- gsub('^\\s*|\\s*$',"",clean1)
  
  # Removing leftover quotation marks.
  clean1 <- gsub('^.*[\\"\\“\\”].*',"",clean1)
  
  # Removing empty lines.
  clean1 <- clean1[clean1 != ""]
  
  #The cleaned texts are written out to TXT files, each with the same name as their original PDF file.
  writeLines(clean1, con = gsub("\\.pdf", "\\.txt", i), useBytes=T)
}
# All done! The regular expressions could probably be optimized better, but why fix what isn't broken.
