(lang dune 3.11)

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
 (depends dream-html tyxml ppx_inline_test core ocaml dune (alcotest :with-test) dream)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
