enum TTSType {
  polly,
}

enum Voice {
  lotte(name: "Lotte"),
  maxim(name: "Maxim"),
  ayanda(name: "Ayanda"),
  salli(name: "Salli"),
  ola(name: "Ola"),
  arthur(name: "Arthur"),
  ida(name: "Ida"),
  tomoko(name: "Tomoko"),
  remi(name: "Remi"),
  geraint(name: "Geraint"),
  miguel(name: "Miguel"),
  elin(name: "Elin"),
  lisa(name: "Lisa"),
  giorgio(name: "Giorgio"),
  marlene(name: "Marlene"),
  ines(name: "Ines"),
  kajal(name: "Kajal"),
  zhiyu(name: "Zhiyu"),
  zeina(name: "Zeina"),
  suvi(name: "Suvi"),
  karl(name: "Karl"),
  gwyneth(name: "Gwyneth"),
  joanna(name: "Joanna"),
  lucia(name: "Lucia"),
  cristiano(name: "Cristiano"),
  astrid(name: "Astrid"),
  andres(name: "Andres"),
  vicki(name: "Vicki"),
  mia(name: "Mia"),
  vitoria(name: "Vitoria"),
  bianca(name: "Bianca"),
  chantal(name: "Chantal"),
  raveena(name: "Raveena"),
  daniel(name: "Daniel"),
  amy(name: "Amy"),
  liam(name: "Liam"),
  ruth(name: "Ruth"),
  kevin(name: "Kevin"),
  brian(name: "Brian"),
  russell(name: "Russell"),
  aria(name: "Aria"),
  matthew(name: "Matthew"),
  aditi(name: "Aditi"),
  zayd(name: "Zayd"),
  dora(name: "Dora"),
  enrique(name: "Enrique"),
  hans(name: "Hans"),
  hiujin(name: "Hiujin"),
  carmen(name: "Carmen"),
  sofie(name: "Sofie"),
  ivy(name: "Ivy"),
  ewa(name: "Ewa"),
  maja(name: "Maja"),
  gabrielle(name: "Gabrielle"),
  nicole(name: "Nicole"),
  filiz(name: "Filiz"),
  camila(name: "Camila"),
  jacek(name: "Jacek"),
  thiago(name: "Thiago"),
  justin(name: "Justin"),
  celine(name: "Celine"),
  kazuha(name: "Kazuha"),
  kendra(name: "Kendra"),
  arlet(name: "Arlet"),
  ricardo(name: "Ricardo"),
  mads(name: "Mads"),
  hannah(name: "Hannah"),
  mathieu(name: "Mathieu"),
  lea(name: "Lea"),
  sergio(name: "Sergio"),
  hala(name: "Hala"),
  tatyana(name: "Tatyana"),
  penelope(name: "Penelope"),
  naja(name: "Naja"),
  olivia(name: "Olivia"),
  ruben(name: "Ruben"),
  laura(name: "Laura"),
  takumi(name: "Takumi"),
  mizuki(name: "Mizuki"),
  carla(name: "Carla"),
  conchita(name: "Conchita"),
  jan(name: "Jan"),
  kimberly(name: "Kimberly"),
  liv(name: "Liv"),
  adriano(name: "Adriano"),
  lupe(name: "Lupe"),
  joey(name: "Joey"),
  pedro(name: "Pedro"),
  seoyeon(name: "Seoyeon"),
  emma(name: "Emma"),
  niamh(name: "Niamh"),
  stephen(name: "Stephen");

  const Voice({
    required this.name,
  });

  final String name;
  final TTSType _type = TTSType.polly;

  static Voice called(String name) {
    return Voice.values
        .firstWhere((e) => e.name == name, orElse: () => Voice.matthew);
  }

  bool get isAWSPolly => _type == TTSType.polly;

  TTSType get type => _type;
}
