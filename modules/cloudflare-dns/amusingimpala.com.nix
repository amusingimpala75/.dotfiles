{
  cloudflare-dns."amusingimpala.com" = {
    CNAME = {
      "*" = "uixie.porkbun.com";
    };
    MX = [
      "fwd1.porkbun.com"
      "fwd2.porkbun.com"
    ];
    TXT = [
      {
        name = "_acme-challenge";
        content = "\"p9at7-oulXa9RED2C8hnPPa1Vst4qI5XzDrzxCXcUbI\"";
      }
      {
        name = "_acme-challenge";
        content = "\"-uzX8sWHBQhNMW_q-A3w5nrh8vE59aCnhg0SFFKW6Kw\"";
      }
      {
        name = "";
        content = "\"v=spf1 include:_spf.porkbun.com ~all\"";
      }
    ];
  };
}
