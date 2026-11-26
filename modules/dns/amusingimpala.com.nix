{
  # HTTPS configuration
  cloudflare-dns."amusingimpala.com"."_acme-challenge".TXT = [
    { content = "\"p9at7-oulXa9RED2C8hnPPa1Vst4qI5XzDrzxCXcUbI\""; }
    { content = "\"-uzX8sWHBQhNMW_q-A3w5nrh8vE59aCnhg0SFFKW6Kw\""; }
  ];
}
