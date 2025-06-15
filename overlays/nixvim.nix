self: final: prev: {
  my-nvim = self.nixvimConfigurations.${final.system}.nixvim.config.build.package;
}
