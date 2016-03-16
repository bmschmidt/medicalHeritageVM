import regex as re
import glob

search_term = "[Nn]eurasthenia"


def print_matching_paragraphs(regular_expression,output_file):
    output_file = open(output_file,"w") # (The "w" means "allow writing")
    for filename in glob.glob("sample_journals/*/*"):
        for paragraph in file_into_paragraphs(filename):
            if re.search(regular_expression,paragraph):
                # If there's a match, we write to the output.
                output_file.write(paragraph + "\n")


def file_into_paragraphs(filename):
    """
    A function that takes a filename, breaks
    the document located there into paragraphs,
    and returns the paragraphs one at a time.
    """
    file = open(filename)
    current_paragraph = ""
    for line in file:
        # Trailing hyphens should run up against the next line.
        line = line.replace("-\n","")
        # In other cases, the trailing newline is a space
        line = line.replace("\n"," ")
        if line==" ":
            # If the line is blank, we're at
            # a break between paragraphs.
            # So give back the old paragraph,
            # and then start afresh.
            yield current_paragraph
            current_paragraph=""            
        else:
            # Otherwise, just stack it onto the queue.
            current_paragraph = current_paragraph + line        
    # At the end, return the last paragraph.
    yield current_paragraph


# If you want to save to some other file, just change the text here.
output_file = search_term + ".txt"
    
if __name__=="__main__":
    print_matching_paragraphs(search_term,output_file)
