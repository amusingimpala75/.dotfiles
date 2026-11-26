{
  cloudflare-dns."amusingimpala.com" = {
    # GitHub Pages
    "@".A = map (content: { inherit content; }) [
      "185.199.108.153"
      "185.199.109.153"
      "185.199.110.153"
      "185.199.111.153"
    ];
    "@".AAAA = map (content: { inherit content; }) [
      "2606:50c0:8000::153"
      "2606:50c0:8001::153"
      "2606:50c0:8002::153"
      "2606:50c0:8003::153"
    ];
    "avogadrio".CNAME = [ { content = "amusingimpala75.github.io"; } ];
    "memory".CNAME = [ { content = "amusingimpala75.github.io"; } ];
    "www".CNAME = [ { content = "amusingimpala75.github.io"; } ];
    "utils".CNAME = [ { content = "amusingimpala75.github.io"; } ];
  };
}
