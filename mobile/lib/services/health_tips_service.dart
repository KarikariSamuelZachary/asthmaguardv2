// Required for IconData in asthmaTipCategories if used here
import 'package:mobile/data/health_tip_model.dart'; // Adjust path if necessary

class HealthTipsService {
  // Mock data for asthma health tips
  final List<HealthTip> _mockAsthmaTips = [
    HealthTip(
      id: 'asthma_2',
      category: 'medication',
      title: 'Proper Inhaler Technique',
      description:
          'Ensure you are using your inhaler correctly for maximum effectiveness. Watch a video guide.',
      type: 'video',
      imageUrl:
          'https://images.pexels.com/photos/3952234/pexels-photo-3952234.jpeg?auto=compress&w=800',
      url: 'https://www.youtube.com/watch?v=T_4_1MignhA',
    ),
    HealthTip(
      id: 'asthma_3',
      category: 'breathing_exercises',
      title: 'Pursed Lip Breathing Exercise',
      description:
          'Practice pursed lip breathing to help control shortness of breath during an asthma flare-up.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&auto=format&fit=crop',
      url:
          'https://www.lung.org/lung-health-diseases/lung-disease-lookup/asthma/living-with-asthma/managing-asthma/breathing-exercises',
    ),
    HealthTip(
      id: 'asthma_4',
      category: 'emergency_actions',
      title: 'What To Do During an Asthma Attack',
      description:
          'Know the steps to take if you or someone else is having an asthma attack. Includes when to call for emergency help.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800&auto=format&fit=crop',
      url: 'https://www.asthma.org.uk/advice/asthma-attacks/',
    ),
    HealthTip(
      id: 'asthma_5',
      category: 'lifestyle',
      title: 'Keep Your Home Smoke-Free',
      description:
          'Avoid smoking and secondhand smoke to reduce asthma symptoms.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800&auto=format&fit=crop',
      url: 'https://www.cdc.gov/tobacco/basic_information/secondhand_smoke/',
    ),
    HealthTip(
      id: 'asthma_6',
      category: 'lifestyle',
      title: 'Monitor Air Quality',
      description:
          'Check daily air quality reports and limit outdoor activity on high pollution days.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1464983953574-0892a716854b?w=800&auto=format&fit=crop',
      url: 'https://www.airnow.gov/',
    ),
    HealthTip(
      id: 'asthma_7',
      category: 'medication',
      title: 'Create an Asthma Action Plan',
      description:
          'Work with your doctor to develop a personalized asthma action plan.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?w=800&auto=format&fit=crop',
      url: 'https://www.cdc.gov/asthma/actionplan.html',
    ),
    HealthTip(
      id: 'asthma_8',
      category: 'trigger_avoidance',
      title: 'Control Dust Mites',
      description:
          'Use allergen-proof mattress covers and wash bedding weekly in hot water.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1504196606672-aef5c9cefc92?w=800&auto=format&fit=crop',
      url: 'https://www.aafa.org/dust-mite-allergy/',
    ),
    HealthTip(
      id: 'asthma_9',
      category: 'trigger_avoidance',
      title: 'Manage Pet Allergies',
      description:
          'Keep pets out of bedrooms and bathe them regularly to reduce dander.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1518717758536-85ae29035b6d?w=800&auto=format&fit=crop',
      url: 'https://www.aafa.org/pet-dog-cat-allergies/',
    ),
    HealthTip(
      id: 'asthma_10',
      category: 'lifestyle',
      title: 'Exercise Safely',
      description: 'Warm up before exercise and carry your inhaler if needed.',
      type: 'article',
      imageUrl:
          'https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg?auto=compress&w=800',
      url: 'https://www.aafa.org/exercise-induced-asthma/',
    ),
    HealthTip(
      id: 'asthma_11',
      category: 'breathing_exercises',
      title: 'Diaphragmatic Breathing',
      description: 'Practice belly breathing to improve lung function.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?w=800&auto=format&fit=crop',
      url:
          'https://www.lung.org/lung-health-diseases/wellness/breathing-exercises',
    ),
    HealthTip(
      id: 'asthma_12',
      category: 'emergency_actions',
      title: 'Recognize Asthma Warning Signs',
      description:
          'Know early warning signs like coughing, wheezing, and chest tightness.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&auto=format&fit=crop',
      url: 'https://www.cdc.gov/asthma/faqs.htm',
    ),
    HealthTip(
      id: 'asthma_13',
      category: 'medication',
      title: 'Store Medication Properly',
      description:
          'Keep asthma medication in a cool, dry place and check expiration dates.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1516574187841-cb9cc2ca948b?w=800&auto=format&fit=crop',
      url:
          'https://www.fda.gov/drugs/safe-disposal-medicines/disposal-unused-medicines-what-you-should-know',
    ),
    HealthTip(
      id: 'asthma_14',
      category: 'trigger_avoidance',
      title: 'Reduce Mold Exposure',
      description: 'Fix leaks and use a dehumidifier to prevent mold growth.',
      type: 'article',
      imageUrl:
          'https://images.pexels.com/photos/207983/pexels-photo-207983.jpeg?auto=compress&w=800',
      url: 'https://www.epa.gov/mold',
    ),
    HealthTip(
      id: 'asthma_15',
      category: 'lifestyle',
      title: 'Eat a Healthy Diet',
      description:
          'A balanced diet supports your immune system and overall health.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&auto=format&fit=crop',
      url: 'https://www.cdc.gov/nutrition/',
    ),
    HealthTip(
      id: 'asthma_16',
      category: 'lifestyle',
      title: 'Stay Hydrated',
      description: 'Drink plenty of water to keep airways moist.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1502741338009-cac2772e18bc?w=800&auto=format&fit=crop',
      url: 'https://www.cdc.gov/healthywater/drinking/',
    ),
    HealthTip(
      id: 'asthma_17',
      category: 'trigger_avoidance',
      title: 'Limit Outdoor Activity During Allergy Season',
      description: 'Stay indoors when pollen counts are high.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?w=800&auto=format&fit=crop',
      url: 'https://www.cdc.gov/asthma/pollen.html',
    ),
    HealthTip(
      id: 'asthma_18',
      category: 'emergency_actions',
      title: 'Teach Others About Your Asthma',
      description: 'Let friends and family know what to do in an emergency.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?w=800&auto=format&fit=crop',
      url: 'https://www.aafa.org/asthma-emergency/',
    ),
    HealthTip(
      id: 'asthma_19',
      category: 'breathing_exercises',
      title: 'Buteyko Breathing Technique',
      description:
          'A method to help reduce asthma symptoms by breathing slowly and gently.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?w=800&auto=format&fit=crop',
      url: 'https://www.healthline.com/health/buteyko-breathing-technique',
    ),
    HealthTip(
      id: 'asthma_20',
      category: 'lifestyle',
      title: 'Get Regular Checkups',
      description:
          'Visit your doctor regularly to review your asthma management plan.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&auto=format&fit=crop',
      url: 'https://www.cdc.gov/asthma/healthcare.html',
    ),
    HealthTip(
      id: 'asthma_21',
      category: 'medication',
      title: 'Know Your Medication Side Effects',
      description:
          'Be aware of possible side effects and talk to your doctor if you have concerns.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1516574187841-cb9cc2ca948b?w=800&auto=format&fit=crop',
      url: 'https://www.cdc.gov/asthma/medication.html',
    ),
    HealthTip(
      id: 'asthma_22',
      category: 'trigger_avoidance',
      title: 'Avoid Strong Odors',
      description:
          'Perfumes, cleaning products, and paints can trigger asthma symptoms.',
      type: 'article',
      imageUrl:
          'https://images.pexels.com/photos/461428/pexels-photo-461428.jpeg?auto=compress&w=800',
      url: 'https://www.aafa.org/strong-odors/',
    ),
    HealthTip(
      id: 'asthma_23',
      category: 'lifestyle',
      title: 'Practice Good Sleep Hygiene',
      description:
          'Get enough sleep to help your body recover and manage asthma.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800&auto=format&fit=crop',
      url: 'https://www.sleepfoundation.org/',
    ),
    HealthTip(
      id: 'asthma_24',
      category: 'emergency_actions',
      title: 'Keep Emergency Contacts Handy',
      description:
          'Have a list of emergency contacts and your asthma action plan accessible.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?w=800&auto=format&fit=crop',
      url: 'https://www.cdc.gov/asthma/emergency.html',
    ),
    HealthTip(
      id: 'asthma_25',
      category: 'breathing_exercises',
      title: 'Try Yoga for Asthma',
      description: 'Yoga can help improve breathing and reduce stress.',
      type: 'article',
      imageUrl:
          'https://images.pexels.com/photos/317157/pexels-photo-317157.jpeg?auto=compress&w=800',
      url: 'https://www.aafa.org/yoga-and-asthma/',
    ),
    HealthTip(
      id: 'asthma_26',
      category: 'lifestyle',
      title: 'Manage Stress',
      description:
          'Stress can worsen asthma symptoms. Practice relaxation techniques.',
      type: 'article',
      imageUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&auto=format&fit=crop',
      url: 'https://www.cdc.gov/mentalhealth/stress-coping/',
    ),
    HealthTip(
      id: 'asthma_100',
      category: 'lifestyle',
      title: 'Stay Active with Light Exercise',
      description:
          'Gentle activities like walking or stretching can help lung health.',
      type: 'article',
      imageUrl:
          'https://images.pexels.com/photos/375737/pexels-photo-375737.jpeg?auto=compress&w=800',
      url:
          'https://www.lung.org/lung-health-diseases/wellness/exercise-and-lung-health',
    ),
    HealthTip(
      id: 'asthma_102',
      category: 'trigger_avoidance',
      title: 'Keep Windows Closed During High Pollen',
      description: 'Close windows on high pollen days to keep allergens out.',
      type: 'article',
      imageUrl:
          'https://images.pexels.com/photos/221457/pexels-photo-221457.jpeg?auto=compress&w=800',
      url: 'https://www.aafa.org/pollen-allergy/',
    ),
    HealthTip(
      id: 'asthma_103',
      category: 'lifestyle',
      title: 'Wash Hands Frequently',
      description:
          'Reduce the risk of respiratory infections by washing hands often.',
      type: 'article',
      imageUrl:
          'https://images.pexels.com/photos/545013/pexels-photo-545013.jpeg?auto=compress&w=800',
      url: 'https://www.cdc.gov/handwashing/when-how-handwashing.html',
    ),
    HealthTip(
      id: 'asthma_104',
      category: 'lifestyle',
      title: 'Keep Pets Groomed',
      description: 'Regularly bathe and brush pets to reduce dander.',
      type: 'article',
      imageUrl:
          'https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&w=800',
      url: 'https://www.aafa.org/pet-dog-cat-allergies/',
    ),
    HealthTip(
      id: 'asthma_105',
      category: 'lifestyle',
      title: 'Use Fragrance-Free Products',
      description: 'Choose fragrance-free cleaning and personal care products.',
      type: 'article',
      imageUrl:
          'https://images.pexels.com/photos/373564/pexels-photo-373564.jpeg?auto=compress&w=800',
      url: 'https://www.aafa.org/strong-odors/',
    ),
    HealthTip(
      id: 'asthma_106',
      category: 'lifestyle',
      title: 'Elevate Your Head While Sleeping',
      description:
          'Sleeping with your head elevated can help reduce nighttime symptoms.',
      type: 'article',
      imageUrl:
          'https://images.pexels.com/photos/935777/pexels-photo-935777.jpeg?auto=compress&w=800',
      url: 'https://www.sleepfoundation.org/',
    ),
    HealthTip(
      id: 'asthma_107',
      category: 'lifestyle',
      title: 'Stay Hydrated with Water',
      description: 'Drinking water helps keep airways moist and healthy.',
      type: 'article',
      imageUrl:
          'https://images.pexels.com/photos/416528/pexels-photo-416528.jpeg?auto=compress&w=800',
      url: 'https://www.cdc.gov/healthywater/drinking/',
    ),
    HealthTip(
      id: 'asthma_108',
      category: 'lifestyle',
      title: 'Practice Mindful Breathing',
      description:
          'Mindful breathing can help manage stress and asthma symptoms.',
      type: 'article',
      imageUrl:
          'https://images.pexels.com/photos/1051838/pexels-photo-1051838.jpeg?auto=compress&w=800',
      url:
          'https://www.lung.org/lung-health-diseases/wellness/breathing-exercises',
    ),
    HealthTip(
      id: 'asthma_109',
      category: 'lifestyle',
      title: 'Keep a Symptom Diary',
      description:
          'Track your symptoms to help your doctor adjust your treatment.',
      type: 'article',
      imageUrl:
          'https://images.pexels.com/photos/261169/pexels-photo-261169.jpeg?auto=compress&w=800',
      url: 'https://www.cdc.gov/asthma/symptoms.html',
    ),
  ]
      .where((tip) =>
          tip.id != 'asthma_1' &&
          tip.id != 'asthma_27' &&
          tip.id != 'asthma_101')
      .toList();

  Future<Map<String, dynamic>> fetchAsthmaHealthTips({
    int page = 1,
    int limit = 6, // Default items per page
    String category = 'all',
    String searchQuery = '',
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    List<HealthTip> tipsToFilter = List.from(_mockAsthmaTips);

    // Filter by category
    if (category != 'all') {
      tipsToFilter =
          tipsToFilter.where((tip) => tip.category == category).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      tipsToFilter = tipsToFilter.where((tip) {
        return tip.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            tip.description.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Paginate
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    bool hasMore = endIndex < tipsToFilter.length;

    List<HealthTip> paginatedTips = tipsToFilter.sublist(
        startIndex, endIndex.clamp(0, tipsToFilter.length));

    return {
      'tips': paginatedTips,
      'hasMore': hasMore,
      'currentPage': page,
      'totalResults': tipsToFilter.length, // Useful for display
    };
  }
}
