{
  cloudflare-dns."amusingimpala.com" = {
    # GitHub's IPv4
    A = [
      "185.199.108.153"
      "185.199.109.153"
      "185.199.110.153"
      "185.199.111.153"
    ];
    # GitHub's IPv6
    AAAA = [
      "2606:50c0:8000::153"
      "2606:50c0:8001::153"
      "2606:50c0:8002::153"
      "2606:50c0:8003::153"
    ];
    CNAME = {
      "avogadrio" = "amusingimpala75.github.io";
      "memory" = "amusingimpala75.github.io";
      "www" = "amusingimpala75.github.io";
      "utils" = "amusingimpala75.github.io";
    };
  };
}
