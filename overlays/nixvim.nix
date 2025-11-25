self: final: prev: {
  my-nvim =
    self.nixvimConfigurations.${final.stdenv.hostPlatform.system}.nixvim.config.build.package
    // {
      meta.description = "My custom neovim configuration";
      pname = "nvim";
    };
}
