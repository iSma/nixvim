{ lib, pkgs, ... }:
lib.nixvim.plugins.mkNeovimPlugin {
  name = "papis";
  packPathName = "papis.nvim";
  package = "papis-nvim";

  maintainers = [ lib.maintainers.GaetanLepage ];

  # papis.nvim is an nvim-cmp source too
  imports = [ { cmpSourcePlugins.papis = "papis"; } ];

  extraOptions = {
    yqPackage = lib.mkPackageOption pkgs "yq" {
      nullable = true;
    };
  };
  extraConfig = cfg: {
    extraPackages = [ cfg.yqPackage ];
  };

  settingsOptions = import ./settings-options.nix lib;

  settingsExample = {
    enable_keymaps = true;
    papis_python = {
      dir = "~/Documents/papers";
      info_name = "info.yaml";
      notes_name.__raw = "[[notes.norg]]";
    };
    enable_modules = {
      search = true;
      completion = true;
      cursor-actions = true;
      formatter = true;
      colors = true;
      base = true;
      debug = false;
    };
    cite_formats = {
      tex = [
        "\\cite{%s}"
        "\\cite[tp]?%*?{%s}"
      ];
      markdown = "@%s";
      rmd = "@%s";
      plain = "%s";
      org = [
        "[cite:@%s]"
        "%[cite:@%s]"
      ];
      norg = "{= %s}";
    };
  };
}
