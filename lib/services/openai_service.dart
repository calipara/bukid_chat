import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class OpenAIService {
  // Method to ask farming related questions
  Future<String> askFarmingQuestion(String question) async {
    try {
      // Mock response for testing purposes
      return _getMockResponse(question);
      
      /* Uncomment this section and remove the mock response when you have a valid API key
      final response = await http.post(
        Uri.parse("https://us-central1-dreamflow-dev.cloudfunctions.net/dreamflowOpenaiProxyHttpsFn"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer JeYnymDVWyCP1p2cWk0P-427618800e3313b87deb9c7dd60dd1ae55945b505d9445bf55b8fb04666f2978',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': ApiConstants.farmingChatbotContext,
            },
            {
              'role': 'user',
              'content': question,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 800,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final content = jsonResponse['choices'][0]['message']['content'];
        return content;
      } else {
        return 'Error: Unable to get response. Please check your internet connection and try again.';
      }
      */
    } catch (e) {
      return 'Error: $e';
    }
  }

  // Method to analyze crop or pest from image
  Future<String> analyzeCropImage(Uint8List imageBytes, String question) async {
    try {
      // Mock response for image analysis
      return _getMockImageAnalysisResponse(question);
      
      /* Uncomment this section and remove the mock response when you have a valid API key
      String imageBase64 = base64Encode(imageBytes);
      
      final response = await http.post(
        Uri.parse("https://us-central1-dreamflow-dev.cloudfunctions.net/dreamflowOpenaiProxyHttpsFn"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer JeYnymDVWyCP1p2cWk0P-427618800e3313b87deb9c7dd60dd1ae55945b505d9445bf55b8fb04666f2978',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': ApiConstants.farmingChatbotContext + '\nAnalyze the image and identify any plant diseases, pests, nutrient deficiencies, or growth issues. Provide specific advice for Filipino farmers growing corn or rice.',
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': question.isEmpty ? 'What is wrong with this plant? Please identify any issues and suggest solutions.' : question,
                },
                {
                  'type': 'image_url',
                  'image_url': {"url": "data:image/jpeg;base64," + imageBase64},
                },
              ],
            },
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final content = jsonResponse['choices'][0]['message']['content'];
        return content;
      } else {
        return 'Error: Unable to analyze image. Please check your internet connection and try again. (Status code: ${response.statusCode})';
      }
      */
    } catch (e) {
      return 'Error: $e';
    }
  }
  
  // Method to get farming recommendations based on weather and location
  Future<String> getFarmingRecommendations(String cropType, String weatherCondition, String location) async {
    try {
      final prompt = 'I am a farmer in $location, Philippines growing $cropType. ' +
                     'The weather forecast is: $weatherCondition. ' +
                     'What farming activities should I prioritize in the coming days? ' +
                     'Please provide specific advice on timing, techniques, and precautions.';
      
      // Mock response for recommendations
      return _getMockRecommendationsResponse(cropType, weatherCondition, location);
      
      /* Uncomment this section and remove the mock response when you have a valid API key
      final response = await http.post(
        Uri.parse("https://us-central1-dreamflow-dev.cloudfunctions.net/dreamflowOpenaiProxyHttpsFn"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer JeYnymDVWyCP1p2cWk0P-427618800e3313b87deb9c7dd60dd1ae55945b505d9445bf55b8fb04666f2978',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': ApiConstants.farmingChatbotContext,
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final content = jsonResponse['choices'][0]['message']['content'];
        return content;
      } else {
        return 'Error: Unable to get recommendations. Please check your internet connection and try again.';
      }
      */
    } catch (e) {
      return 'Error: $e';
    }
  }
  
  // Method to get financial advice based on farm data
  Future<String> getFinancialAdvice(String cropType, double expenses, double revenue, double area) async {
    try {
      final prompt = 'I am a $cropType farmer in the Philippines with ${area.toStringAsFixed(2)} hectares of land. ' +
                     'My current expenses are ₱${expenses.toStringAsFixed(2)} and revenue is ₱${revenue.toStringAsFixed(2)}. ' +
                     'Profit margin is ${((revenue - expenses) / expenses * 100).toStringAsFixed(2)}%. ' +
                     'Please provide financial advice to improve profitability. ' +
                     'Include specific suggestions on cost reduction and revenue optimization for $cropType farming in the Philippines.';
      
      // Mock response for financial advice
      return _getMockFinancialAdviceResponse(cropType, expenses, revenue, area);
      
      /* Uncomment this section and remove the mock response when you have a valid API key
      final response = await http.post(
        Uri.parse("https://us-central1-dreamflow-dev.cloudfunctions.net/dreamflowOpenaiProxyHttpsFn"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer JeYnymDVWyCP1p2cWk0P-427618800e3313b87deb9c7dd60dd1ae55945b505d9445bf55b8fb04666f2978',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a financial advisor specializing in Philippine agriculture, particularly for small to medium-scale farmers. Provide practical, actionable financial advice specific to the Philippine context.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 600,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final content = jsonResponse['choices'][0]['message']['content'];
        return content;
      } else {
        return 'Error: Unable to get financial advice. Please check your internet connection and try again.';
      }
      */
    } catch (e) {
      return 'Error: $e';
    }
  }
  
  // Mock responses for testing
  String _getMockResponse(String question) {
    if (question.contains('palay') || question.contains('rice')) {
      return "Para sa matagumpay na pagtatanim ng palay, mahalagang sundin ang mga tamang hakbang:"
          "\n\n1. **Paghahanda ng Lupa**:"
          "\n   - Araruhin ang lupa ng 2-3 beses para mabali ang mga piraso ng lupa"
          "\n   - Patubigan ang bukid at suyurin nang 1-2 beses para pantayin ang lupa"
          "\n   - Linisin ang mga kanal para sa maayos na daloy ng tubig"
          "\n\n2. **Pagpili ng Binhi**:"
          "\n   - Gumamit ng de-kalidad at sertipikadong binhi mula sa PhilRice o IRRI"
          "\n   - Piliin ang mga bariyedad na angkop sa iyong lokasyon at panahon"
          "\n   - Para sa tag-ulan, maganda ang NSIC Rc222, Rc216, at Rc402"
          "\n\n3. **Pagsasabog o Pagtatanim**:"
          "\n   - Maaaring magsabog ng binhi o magtanim ng punla"
          "\n   - Sa direktang pagsasabog, 40-60 kg ng binhi kada ektarya"
          "\n   - Sa paglilipat-tanim, 20-25 kg ng binhi kada ektarya"
          "\n\nHuwag mag-atubiling magtanong pa tungkol sa ibang aspeto ng pagpapalayan!";
    } else if (question.contains('mais') || question.contains('corn')) {
      return "Para sa matagumpay na pagtatanim ng mais, narito ang mga mahahalagang gabay:"
          "\n\n1. **Paghahanda ng Lupa**:"
          "\n   - Araruhin ang lupa ng 1-2 beses at suyurin para maalis ang mga damo"
          "\n   - Kung hindi masyadong mausok ang lupa, pwedeng direct seeding na"
          "\n   - Gumawa ng mga tudling na may distansyang 75 cm ang bawat isa"
          "\n\n2. **Pagpili ng Binhi**:"
          "\n   - Para sa yellow corn, maaaring gumamit ng mga hybrid seeds para sa mataas na ani"
          "\n   - Para sa white corn o glutinous corn, may mga open-pollinated varieties na pwede"
          "\n   - Piliin ang binhi batay sa resistensya sa peste at sakit na karaniwang problema sa inyong lugar"
          "\n\n3. **Pagtatanim**:"
          "\n   - Magtanim sa distansyang 75 cm x 25 cm (75 cm between rows, 25 cm between hills)"
          "\n   - Maglagay ng 1-2 butil sa bawat butas"
          "\n   - Magtanim sa lalim na 2.5-3.0 cm"
          "\n\nKung may katanungan ka pa tungkol sa pag-aabono, pagkontrol ng peste, o pag-harvest, huwag mag-atubiling magtanong!";
    } else {
      return "Bilang isang farming assistant para sa mga magsasaka ng palay at mais sa Pilipinas, masasagot ko ang iyong mga katanungan tungkol sa:"
          "\n\n1. **Paghahanda ng lupa** - paano ihanda ang bukid bago magtanim"
          "\n2. **Pagpili at paghahanda ng binhi** - anong mga uri ng binhi ang maganda sa iyong lugar"
          "\n3. **Pagtatanim** - tamang distansya, panahon, at technique ng pagtatanim"
          "\n4. **Pag-aabono** - tamang dami at uri ng abono"
          "\n5. **Pagkontrol ng peste at sakit** - pagtukoy at paggamot ng mga problema"
          "\n6. **Pag-aani at post-harvest** - tamang panahon at technique ng pag-aani"
          "\n7. **Marketing** - mga estratehiya para makakuha ng magandang presyo"
          "\n\nMaaari mo ring i-upload ang mga larawan ng iyong pananim para matulungan kitang tukuyin ang mga problema tulad ng peste o sakit. Ano ang gusto mong malaman ngayon?";
    }
  }
  
  String _getMockImageAnalysisResponse(String question) {
    return "**Pagsusuri sa Larawan ng Pananim**\n\n"  
        "Sa aking pagsusuri, ang pananim na ipinakita sa larawan ay nagpapakita ng mga sintomas ng **leaf blight disease**, na karaniwan sa mais at palay sa Pilipinas. Ito ay maaaring dulot ng fungal pathogen tulad ng *Helminthosporium* o *Bipolaris* species.\n\n"
        "**Mga Sintomas na Nakikita:**\n"
        "- Mga kayumangging batik o lesions sa mga dahon\n"
        "- Pagkawala ng kulay (chlorosis) sa paligid ng mga lesion\n"
        "- Pagtuyo at pagkamatay ng mga apektadong bahagi ng dahon\n\n"
        "**Rekomendasyon para sa Paggamot:**\n\n"
        "1. **Immediate Actions:**\n"
        "   - Alisin at sunugin ang mga lubhang apektadong dahon para maiwasan ang pagkalat\n"
        "   - Iwasan ang sobrang patubig dahil umuunlad ang fungi sa mahalumigmig na kapaligiran\n\n"
        "2. **Fungicide Treatment:**\n"
        "   - Mag-spray ng fungicide na may aktibong sangkap na mancozeb o propiconazole\n"
        "   - Sundin ang tamang dosis na nakasaad sa produkto (karaniwan 2.5-3 tablespoons kada 16L na sprayer)\n"
        "   - Mag-spray tuwing umaga kapag tuyo na ang hamog para mas mabisa\n\n"
        "3. **Pag-iwas sa Hinaharap:**\n"
        "   - Gamitin ang resistant varieties sa susunod na taniman\n"
        "   - I-rotate ang mga pananim para maputol ang cycle ng pathogen\n"
        "   - Panatilihin ang tamang distansya ng pagtatanim para sa maayos na daloy ng hangin\n"
        "   - Gumamit ng balanced fertilization para madagdagan ang resistensya ng halaman\n\n"
        "Kung patuloy ang problema o lumalala, kumunsulta sa pinakamalapit na agricultural technician ng inyong munisipyo para sa mas detalyadong pagsusuri at rekomendasyon.";
  }
  
  String _getMockRecommendationsResponse(String cropType, String weatherCondition, String location) {
    if (weatherCondition.contains('Rain') || weatherCondition.contains('rain')) {
      return "**Mga Rekomendasyon sa Pagsasaka ng $cropType sa $location**\n\n"
          "Batay sa kasalukuyang weather condition na may pag-ulan, narito ang mga rekomendasyon para sa iyong bukid:\n\n"
          "**1. Drainage Management:**\n"
          "- Siguruhin na maayos ang mga kanal sa paligid ng bukid para maiwasang bumaha\n"
          "- Linisin ang mga drainage canals para sa maayos na daloy ng tubig\n"
          "- Maghanda ng mga sandbags para sa areas na madalas bahain\n\n"
          "**2. Pest at Disease Monitoring:**\n"
          "- Mas tumataas ang risk ng fungal diseases sa panahon ng tag-ulan\n"
          "- Regular na i-monitor ang mga halaman para sa anumang sintomas ng sakit, lalo na ang rice blast at bacterial leaf blight\n"
          "- Maghanda ng fungicides (propiconazole o mancozeb) para sa preventive application\n\n"
          "**3. Nutrient Management:**\n"
          "- Iwasan ang pag-apply ng fertilizer habang malakas ang ulan para hindi ma-wash out\n"
          "- Pagkatapos ng ulan, consider applying nitrogen fertilizer para mapalitan ang nutrients na nawala\n"
          "- Gumamit ng slow-release fertilizers para sa mas sustained na nutrition\n\n"
          "**4. Timing ng Activities:**\n"
          "- Ipagpaliban muna ang spraying operations sa panahon ng ulan\n"
          "- Unahin ang pag-harvest ng mature crops para hindi mabasa at masira\n"
          "- Gumawa ng pagtatrabaho sa field tuwing may break sa ulan\n\n"
          "Maghanda para sa posibilidad ng extended na tag-ulan sa darating na mga araw, at siguruhing laging dry at ventilated ang mga naimbak na seeds at harvested products.";
    } else if (weatherCondition.contains('Clear') || weatherCondition.contains('Sunny')) {
      return "**Mga Rekomendasyon sa Pagsasaka ng $cropType sa $location**\n\n"
          "Batay sa kasalukuyang clear/sunny weather condition, narito ang mga rekomendasyon para sa iyong bukid:\n\n"
          "**1. Water Management:**\n"
          "- Siguruhing sapat ang patubig sa iyong bukid, lalo na sa mga araw na mataas ang temperature\n"
          "- Mag-irrigate ng maaga sa umaga o late afternoon para mabawasan ang evaporation\n"
          "- Check ang moisture level ng lupa bago magpatubig para iwasan ang overwatering o underwatering\n\n"
          "**2. Ideal Activities sa Magandang Panahon:**\n"
          "- Magandang panahon para sa land preparation at direct seeding\n"
          "- Optimal time para sa fertilizer application (early morning)\n"
          "- Perfect conditions for spraying pesticides/herbicides (no wind, no rain forecast)\n"
          "- Ideal para sa pagba-broadcast ng fertilizer\n\n"
          "**3. Heat Protection para sa Crops:**\n"
          "- Mag-mulch sa soil para ma-conserve ang moisture at ma-regulate ang soil temperature\n"
          "- Provide temporary shade sa newly planted seedlings kung sobrang init\n"
          "- Mag-monitor sa possible heat stress symptoms (leaf rolling, wilting)\n\n"
          "**4. Harvest at Post-Harvest:**\n"
          "- Magandang panahon para sa pag-harvest ng mature crops\n"
          "- Ideal para sa pagpapatuyo ng grains sa sun drying\n"
          "- I-monitor ang moisture content ng grains para sa tamang pag-imbak\n\n"
          "Samantalahin ang magandang panahon para sa mga outdoor activities, pero maghanda pa rin sa possible changes sa weather patterns sa darating na mga araw.";
    } else {
      return "**Mga Rekomendasyon sa Pagsasaka ng $cropType sa $location**\n\n"
          "Batay sa kasalukuyang weather condition: $weatherCondition, narito ang mga rekomendasyon para sa iyong bukid:\n\n"
          "**1. Regular Monitoring:**\n"
          "- I-monitor ang weather forecasts daily para sa potential changes\n"
          "- I-check regularly ang iyong crops para sa anumang signs ng stress o sakit\n"
          "- Obserbahan ang soil moisture levels para matukoy kung kailangan ng irrigation\n\n"
          "**2. Balanced Crop Management:**\n"
          "- Maintain proper spacing sa pagitan ng plants para sa adequate airflow\n"
          "- Follow recommended fertilization schedules based sa growth stage\n"
          "- Practice integrated pest management para sa sustainable control\n\n"
          "**3. Contingency Planning:**\n"
          "- Maghanda ng mga tools at equipment para sa quick response sa sudden weather changes\n"
          "- Have alternative plans sa case na hindi favorable ang weather for critical activities\n"
          "- Magtabi ng emergency supplies kung sakaling may sudden severe weather\n\n"
          "**4. Soil Health Improvement:**\n"
          "- Consider applying organic matter para improve soil structure at water retention\n"
          "- Practice minimal tillage kung applicable para reduce soil erosion\n"
          "- Implement crop rotation para sa long-term soil health\n\n"
          "Regular na kumonsulta sa agricultural extension workers sa iyong area para sa location-specific advice based sa current conditions at forecasts.";
    }
  }
  
  String _getMockFinancialAdviceResponse(String cropType, double expenses, double revenue, double area) {
    double profitMargin = ((revenue - expenses) / expenses * 100);
    
    if (profitMargin < 20) {
      return "**Financial Advice para sa iyong $cropType Farm**\n\n"
          "Napansin ko na medyo mababa ang kasalukuyang profit margin ng iyong farm (${profitMargin.toStringAsFixed(2)}%). Narito ang ilang rekomendasyon para mapataas ang iyong kita:\n\n"
          "**1. Cost Reduction Strategies:**\n"
          "- **Optimize Input Usage:** Mag-soil test para malaman ang exact fertilizer requirements. Madalas, nagsasayang tayo ng abono dahil hindi tama ang amount na nilalagay.\n"
          "- **Group Purchasing:** Makipag-coordinate sa kapwa farmers para mag-bulk buy ng inputs tulad ng fertilizer at pesticides para makakuha ng discount.\n"
          "- **Equipment Sharing:** Sa halip na bumili ng sariling equipment, makipag-usap sa kapwa farmers para mag-share ng machinery para mabawasan ang capital expenses.\n\n"
          "**2. Revenue Enhancement:**\n"
          "- **Value Addition:** Consider mo ang pagprocess ng iyong $cropType products para masmahal ang bentahan (e.g., cornmeal, corn snacks, milled rice, rice flour).\n"
          "- **Direct Marketing:** Subukan mong magbenta directly sa consumers o sa local markets para maiwasan ang middlemen.\n"
          "- **Crop Diversification:** Consider planting complementary crops para may additional income source at risk management.\n\n"
          "**3. Financing Options:**\n"
          "- **Government Programs:** Apply sa ACPC (Agricultural Credit Policy Council) para sa low-interest loans.\n"
          "- **Crop Insurance:** Kumuha ng insurance sa PCIC (Philippine Crop Insurance Corporation) para protektado ka sa crop failures.\n\n"
          "**4. Long-term Strategy:**\n"
          "- **Sustainable Practices:** Mag-invest sa organic farming o sustainable practices na makakabawas sa input costs over time.\n"
          "- **Mechanization:** Kung kakayanin, unti-unting mag-adopt ng basic mechanization para mabawasan ang labor costs.\n\n"
          "Importante rin na mag-maintain ka ng detailed financial records para mas madaling matukoy kung saan pwedeng i-optimize ang gastos at kita sa iyong farm operations.";
    } else {
      return "**Financial Advice para sa iyong $cropType Farm**\n\n"
          "Nakakagalak na may magandang profit margin (${profitMargin.toStringAsFixed(2)}%) ang iyong farm operations. Narito ang ilang rekomendasyon para mapanatili at mapalakas pa ang financial performance:\n\n"
          "**1. Reinvestment Strategies:**\n"
          "- **Farm Infrastructure:** Mag-invest sa improvements tulad ng irrigation systems, storage facilities, o small processing equipment.\n"
          "- **Technology Adoption:** Consider investing in simple technologies na magpapabilis at magpapagaan ng farm operations.\n"
          "- **Land Expansion:** Kung feasible, consider expanding sa nearby areas para scale-up ang operations.\n\n"
          "**2. Risk Management:**\n"
          "- **Diversification:** Kahit profitable ang $cropType, consider adding complementary crops para ma-distribute ang risk.\n"
          "- **Emergency Fund:** Set aside 15-20% ng profits para sa emergency fund specific sa farm operations.\n"
          "- **Forward Contracts:** Explore possibilities ng forward contracts sa buyers para ma-secure ang prices in advance.\n\n"
          "**3. Market Expansion:**\n"
          "- **Premium Markets:** Explore high-value markets tulad ng organic o specialty $cropType products.\n"
          "- **Value Chain Integration:** Consider vertical integration (e.g., processing, packaging) para sa higher margins.\n"
          "- **Export Potential:** Kung substantial ang production, alamin ang requirements para sa regional exports.\n\n"
          "**4. Financial Planning:**\n"
          "- **Tax Planning:** Consult with an accountant familiar sa agriculture para ma-optimize ang tax benefits for farmers.\n"
          "- **Retirement Planning:** Set up a separate investment vehicle para sa retirement (hindi lahat sa farm na-reinvest).\n"
          "- **Business Structure:** Consider formalizing your farm as a proper business entity para sa better financial management at protection.\n\n"
          "Magandang strategy rin ang pagme-mentor sa ibang farmers para i-share ang best practices mo habang natututo ka rin sa kanilang experiences. Congratulations sa successful operations mo!";
    }
  }
}