{
  lib,
  runCommand,
  pkgs,
}:
let
  # Format a list of errors with an error message and trailing newline
  describeErrors =
    desc: errors:
    lib.optionals (errors != [ ]) (lib.toList desc ++ lib.map (v: "- ${v}") errors ++ [ "" ]);

  # Build error messages for the given declared & generated names
  checkDeclarations =
    {
      # The plugin's name
      name,
      # A list of names declared in declarationFile
      declared,
      # A list of names generated by generate-files
      generated,
      # The filename where names are declared (used in error messages)
      declarationFile,
    }:
    let
      undeclared = lib.filter (name: !(lib.elem name declared)) generated;
      uselesslyDeclared = lib.filter (name: !(lib.elem name generated)) declared;
    in
    describeErrors "${name}: The following are not declared in ${declarationFile}:" undeclared
    ++ describeErrors "${name}: The following are not listed upstream, but are declared in ${declarationFile}:" uselesslyDeclared;

  # The error message provided to the derivation.
  # The test fails if this is non-empty.
  errors = lib.concatStringsSep "\n" (
    checkDeclarations {
      name = "none-ls";
      declarationFile = "plugins/none-ls/packages.nix";

      declared =
        let
          inherit (import ../plugins/none-ls/packages.nix lib) noPackage packaged;
        in
        noPackage ++ lib.attrsets.attrNames packaged;

      generated = lib.pipe ../generated/none-ls.nix [
        import
        lib.attrsets.attrValues
        lib.lists.concatLists
        lib.lists.unique
      ];
    }
    ++ checkDeclarations {
      name = "efmls";
      declarationFile = "efmls-configs-pkgs.nix";

      declared =
        let
          inherit (import ../plugins/lsp/language-servers/efmls-configs-pkgs.nix lib) packaged unpackaged;
        in
        unpackaged ++ lib.attrsets.attrNames packaged;

      generated = lib.pipe ../generated/efmls-configs.nix [
        import
        lib.attrsets.attrValues
        (lib.map ({ linter, formatter }: linter.possible ++ formatter.possible))
        lib.lists.concatLists
        lib.lists.unique
      ];
    }
  );
in
runCommand "generated-sources-test" { inherit errors; } ''
  if [ -n "$errors" ]; then
    echo -n "$errors"
    exit 1
  fi
  touch "$out"
''
