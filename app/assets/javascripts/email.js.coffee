$(() ->
  part1 = "info";
  part2 = "communityrun.org";
  part3 = "contact us";
  part3a = "Contact us";
  $('.contact').html('<a href="mai' + 'lto:' + part1 + '@' + part2 + '">' + part3 + '</a>');
  $('.contact-cap').html('<a href="mai' + 'lto:' + part1 + '@' + part2 + '">' + part3a + '</a>');
)