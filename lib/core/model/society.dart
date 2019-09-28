class Society{
  final String sId;
  final String enName;
  final String hiName;
  final int sector;
  final int plot;

  const Society({this.sId, this.enName, this.hiName, this.sector, this.plot});

  Society.fromMap(Map<String, dynamic> data, String id) : this (
    sId: id,
    enName: data['en'],
    hiName: data['hi'],
    plot: data['plot'],
    sector: data['sector']
  );
}