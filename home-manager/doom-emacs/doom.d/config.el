(setq org-latex-pdf-process
      (let
          ((cmd (concat "pdflatex -shell-escape -interaction nonstopmode"
                        " --synctex=1"
                        " -output-directory %o %f")))
        (list cmd
              "cd %o; if test -r %b.idx; then makeindex %b.idx; fi"
              "cd %o; bibtex %b"
              cmd
              cmd)))
