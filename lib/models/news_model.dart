class AgricultureNewsModel {
  final String title;
  final String summary;
  final String source;
  final DateTime date;
  final String imageUrl;
  final String fullArticleUrl;

  AgricultureNewsModel({
    required this.title,
    required this.summary,
    required this.source,
    required this.date,
    required this.imageUrl,
    required this.fullArticleUrl,
  });
}

// Sample data for Department of Agriculture news
class NewsData {
  static List<AgricultureNewsModel> getAgricultureNews() {
    return [
      AgricultureNewsModel(
        title: 'Department of Agriculture Distributes Free Corn Seeds to Farmers',
        summary: 'The Philippine Department of Agriculture has begun distributing free corn seeds to farmers across Nueva Ecija and Isabela provinces as part of its corn productivity enhancement program.',
        source: 'Department of Agriculture',
        date: DateTime.now().subtract(const Duration(days: 2)),
        imageUrl: "Corn Seeds Agriculture",
        fullArticleUrl: 'https://www.da.gov.ph/programs/corn-productivity',
      ),
      AgricultureNewsModel(
        title: 'New Rice Variety Released: NSIC Rc562',
        summary: 'PhilRice has released a new rice variety coded NSIC Rc562, which has better disease resistance and can yield up to 10 tons per hectare under optimal conditions.',
        source: 'Philippine Rice Research Institute',
        date: DateTime.now().subtract(const Duration(days: 5)),
        imageUrl: "Rice Planting Farming",
        fullArticleUrl: 'https://www.philrice.gov.ph/new-varieties',
      ),
      AgricultureNewsModel(
        title: 'Government Provides Subsidy for Small-Scale Irrigation Systems',
        summary: 'Small-scale farmers can now apply for subsidies for small irrigation systems through their local Municipal Agriculture Office.',
        source: 'Department of Agriculture',
        date: DateTime.now().subtract(const Duration(days: 8)),
        imageUrl: "Irrigation System Agriculture",
        fullArticleUrl: 'https://www.da.gov.ph/programs/irrigation-subsidy',
      ),
      AgricultureNewsModel(
        title: 'Training on Integrated Pest Management for Corn Farmers',
        summary: 'The Agricultural Training Institute will conduct a series of workshops on integrated pest management specifically for corn farmers starting next month.',
        source: 'Agricultural Training Institute',
        date: DateTime.now().subtract(const Duration(days: 10)),
        imageUrl: "Corn Farm Pesticide",
        fullArticleUrl: 'https://www.ati.da.gov.ph/training-calendar',
      ),
      AgricultureNewsModel(
        title: 'PhilMech Introduces New Post-Harvest Technologies',
        summary: 'The Philippine Center for Postharvest Development and Mechanization (PhilMech) has introduced new technologies to reduce post-harvest losses for rice and corn.',
        source: 'PhilMech',
        date: DateTime.now().subtract(const Duration(days: 15)),
        imageUrl: "Post Harvest Technology Agriculture",
        fullArticleUrl: 'https://www.philmech.gov.ph/technologies',
      ),
    ];
  }
}