#-----------------------------------------------------------------
# This is the Makefile for mrr
#
# 18/9/18, PH
#-----------------------------------------------------------------

# project name
PROJ = mrr

# Usually no edits below this line
#-----------------------------------------------------------------
# Output directory
OUTP = output

EXT = ext

# Figures directory
FIGS = $(OUTP)/figures

# Tables directory
TABLES = $(OUTP)/tables

# R output directory
ROUT = $(OUTP)/R

# tex output directory
TEXOUT = $(SRC)

# Source directory
SRC = src

# Data directory
DATA = data

# tmp directory
TMP = $(OUTP)/tmp

# directory for additional pdf files
LIB = lib

# Filename for manuscript
MANUSCRIPT =$(SRC)/$(PROJ)_ms.pdf

# executables
RCC = R CMD BATCH
RM = rm -Rf
#TEX = xelatex -output-directory=../$(TEXOUT)
TEX = xelatex 
BIBTEX = bibtex
PYTHONBIN = python
EMACSINIT = $(EXT)/$(PROJ)_dotemacs 
EMACS = emacs -l ../$(EMACSINIT)
EMACSMSARGS = --batch -f org-latex-export-to-latex --kill
EMACSPARGS =  --batch -f org-beamer-export-to-latex --kill
VIEWBIN = pdfview
PDFMERGEBIN = ext/pdfmerge
CPBIN = cp
MKDIRBIN = mkdir

# list R files
#RFILES = $(wildcard $(SRC)/*.R)
RFILES = $(SRC)/$(PROJ)_do.R \

# list data files
DATAFILES = $(DATA)/$(PROJ).csv \

# list tex files
TEXFILES = $(wildcard $(SRC)/*.tex)
#TEXFILES = $(ORGFILES:$(SRC)/$(PROJ)_ms.org=$(SRC)/$(PROJ)_ms.tex)

# list org files
ORGFILES = $(wildcard $(SRC)/$(PROJ)*.org)

# list additional library files
PDFLIB = $(wildcard $(LIB)/$(PROJ)*.*)

# indicator files to show R file has been run
ROUTFILES = $(RFILES:$(SRC)/%.R=$(ROUT)/%.Rout)

# indicator files to show tex has run
TEXOUTFILES = $(TEXFILES:$(SRC)/%.tex=$(SRC)/%.aux)

# replace tex with pdf to get pdf tex files
PDFTEXFILES = $(TEXOUTFILES:$(SRC)/%.aux=$(SRC)/%.pdf)

# R file dependencies
#$(ROUT)/%.Rout: $(SRC)/%.R $(DATAFILES) \
#                $(SRC)/$(PROJ)_load.R $(SRC)/$(PROJ)_func.R
#	cd $(SRC) && $(RCC) $(notdir $<) ../$(ROUT)/$*.Rout 
$(ROUT)/%.Rout: $(SRC)/%.R $(DATAFILES) \
                $(SRC)/$(PROJ)_load.R 
  #cd $(SRC) && $(RCC) $(notdir $<) ../$(ROUT)/$*.Rout 
	echo "Running $(notdir $<), this may take a while ..." \
	&& cd $(SRC) && $(RCC) $(notdir $<) 

# Rule for $(TEXFILES)
# Convert every org file to LaTeX this is done from within the subfolder
# so be careful with relative paths
$(SRC)/%.tex: $(SRC)/%.org $(ROUTFILES) $(PDFLIB)
	@if [ "$(notdir $<)" = "$(PROJ)_ms.org" ]; then \
		echo "Exporting manuscript from org to LaTeX" \
		&& cd $(SRC) && $(EMACS) $(PROJ)_ms.org $(EMACSMSARGS); \
	else \
		echo "Exporting $(notdir $<) from org to LaTeX" \
		&& cd $(SRC) && $(EMACS) $(notdir $<) $(EMACSPARGS); \
	fi

#$(SRC)/%.tex: $(SRC)/%.org $(ROUTFILES) $(PDFLIB)
#	cd $(SRC) && $(EMACS) $(notdir $<) $(EMACSMSARGS)

# Rule for $(TEXOUTFILES)
# Run every tex file this is done from within the subfolder so be
# careful with relative paths
$(SRC)/%.aux: $(SRC)/%.tex $(ROUTFILES) $(PDFLIB)
	cd $(SRC) && $(TEX) $(notdir $<)
	$(BIBTEX) $(SRC)/$*
	cd $(SRC) && $(TEX) $(notdir $<)
	cd $(SRC) && $(TEX) $(notdir $<) 

# Default entry
all: figures manuscript

# make manuscript
manuscript: figures tex manuscriptview

# make figures
figures: analysis 

# make tex output
tex: analysis $(TEXOUTFILES) $(TEXFILES) 

# make R output
analysis: $(ROUTFILES)

manuscriptview: manuscript
	$(VIEWBIN) $(MANUSCRIPT)

# simulate that R analyses had been done
Rdone:
	for f in $(ROUTFILES); do \
		touch $$f; \
		echo $$f; \
	done

.PHONY: clean texclean Rclean

clean: texclean Rclean rtfclean figclean

texclean: 
	$(RM) $(TEXOUT)/$(PROJ)*.tex
	$(RM) $(TEXOUT)/$(PROJ)*.aux

Rclean: 
	$(RM) $(ROUT)/$(PROJ)*.*

pyclean: 
	$(RM) $(PYOUT)/$(PROJ)*.*

tmpclean:
	$(RM) $(TMP)/*.*

rtfclean:
	$(RM) $(TMP)/*.*
	$(RM) $(SRC)/$(PROJ)*.rtf

figclean: Rclean
	$(RM) $(FIGS)/$(PROJ)*.*
	$(RM) $(TMP)/Fig.pdf

test:
	echo $(PYINPUT)
