{
  # https config
  cloudflare-dns."amusingimpala.com".TXT = [
    {
      name = "_acme-challenge";
      content = "\"p9at7-oulXa9RED2C8hnPPa1Vst4qI5XzDrzxCXcUbI\"";
    }
    {
      name = "_acme-challenge";
      content = "\"-uzX8sWHBQhNMW_q-A3w5nrh8vE59aCnhg0SFFKW6Kw\"";
    }
  ];
}
