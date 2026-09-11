class CreateSoilJobRequest {
  final double nitrogenLevel;
  final double potassiumLevel;
  final double phosphorousLevel;
  final double organicCarbonLevel;
  final double? ironLevel;
  final double? zincLevel;
  final double? manganeseLevel;
  final double? copperLevel;
  final double? boronLevel;
  final double? sulphurLevel;
  final double? salinityLevel;
  final double? electricalConductivity;
  final double? pH;

  const CreateSoilJobRequest({
    required this.nitrogenLevel,
    required this.potassiumLevel,
    required this.phosphorousLevel,
    required this.organicCarbonLevel,
    this.ironLevel,
    this.zincLevel,
    this.manganeseLevel,
    this.copperLevel,
    this.boronLevel,
    this.sulphurLevel,
    this.salinityLevel,
    this.electricalConductivity,
    this.pH,
  });

  Map<String,dynamic> toJson() {
    return {
      'nitrogenLevel': nitrogenLevel,
      'potassiumLevel': potassiumLevel,
      'phosphorousLevel': phosphorousLevel,
      'organicCarbonLevel': organicCarbonLevel,
      if (ironLevel != null) 'ironLevel': ironLevel,
      if (zincLevel != null) 'zincLevel': zincLevel,
      if (manganeseLevel != null) 'manganeseLevel': manganeseLevel,
      if (copperLevel != null) 'copperLevel': copperLevel,
      if (boronLevel != null) 'boronLevel': boronLevel,
      if (sulphurLevel != null) 'sulphurLevel': sulphurLevel,
      if (salinityLevel != null) 'salinityLevel': salinityLevel,
      if (electricalConductivity != null) 'electricalConductivity': electricalConductivity,
      if (pH != null) 'pH': pH,
    };
  }
}