(lang dune 3.0)

(name myPro)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name myPro)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends 
   tyxml
   ppx_inline_test
   core 
   ocaml
   ocamlformat
   ocaml-lsp-server
   dune 
   (alcotest :with-test) 
   dream
   dream-livereload
   )
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
