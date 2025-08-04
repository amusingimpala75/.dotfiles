{
  fetchurl,
}:
{
  set,
  number,
  hash,
}:
fetchurl {
  url = "https://mtgpics.com/pics/art/${set}/${number}.jpg";
  inherit hash;
}
