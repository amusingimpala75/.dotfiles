{
  cloudflare-dns."amusingimpala.com" = {
    TXT = [
      # Demonstrate ownership of domain
      {
        name = "";
        content = "\"apple-domain=0yw82uYdsh7F50Hg\"";
      }
      # List icloud.com as only approved sender
      {
        name = "";
        content = "\"v=spf1 include:icloud.com ~all\"";
      }
    ];
    # List email servers
    MX = [
      "mx01.mail.icloud.com"
      "mx02.mail.icloud.com"
    ];
    # Other email security thing
    CNAME."sig1._domainkey" = "sig1.dkim.amusingimpala.com.at.icloudmailadmin.com";
  };
}
