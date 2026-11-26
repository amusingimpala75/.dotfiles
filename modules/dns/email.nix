{
  cloudflare-dns."amusingimpala.com" = {
    "@".TXT = [
      # Demonstrate ownership of domain
      { content = "\"apple-domain=0yw82uYdsh7F50Hg\""; }
      # List icloud.com as only approved sender
      { content = "\"v=spf1 include:icloud.com ~all\""; }
    ];
    "@".MX = [
      { content = "mx01.mail.icloud.com"; }
      { content = "mx02.mail.icloud.com"; }
    ];
    "sig1._domainkey".CNAME = [
      { content = "sig1.dkim.amusingimpala.com.at.icloudmailadmin.com"; }
    ];
  };
}
