import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'chat_screen.dart'; // No longer needed

class HireLawyerScreen extends StatefulWidget {
  const HireLawyerScreen({super.key});

  @override
  State<HireLawyerScreen> createState() => _HireLawyerScreenState();
}

class _HireLawyerScreenState extends State<HireLawyerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedExpertise;
  String? _selectedState;
  String? _selectedDistrict;
  bool _searchByDistrict = false;

  List<String> _expertiseOptions = [
    'Family Law',
    'Criminal Law',
    'Corporate Law',
    'Property Law',
    'Labour Law',
    'Civil Law',
    'Tax Law',
    'Other',
  ];

  Map<String, List<String>> _stateDistrictMap = {
    'Andhra Pradesh': [
      'Alluri Sitarama Raju', 'Anakapalle', 'Ananthapuramu', 'Annamayya',
      'Bapatla', 'Chittoor', 'East Godavari', 'Eluru',
      'Guntur', 'YSR Kadapa (Cuddapah)', 'Kakinada', 'Krishna',
      'Konaseema', 'Kurnool', 'Parvathipuram Manyam', 'Nandyal',
      'NTR', 'Palnadu', 'Prakasam', 'Nellore',
      'Tirupati', 'Sri Sathya Sai', 'Srikakulam', 'Visakhapatnam',
      'Vizianagaram', 'West Godavari'
    ],
    'Arunachal Pradesh': [
      'Anjaw', 'Changlang', 'Dibang Valley', 'East Kameng', 'East Siangl',
      'Kamle', 'Kra Daadi', 'Kurung Kumey', 'Lepa Rada', 'Lohit',
      'Longdling', 'Lower Dibang Valley', 'Lower Siang', 'Lower Subansiri', 'Namsai',
      'Pakke Kessang', 'Papum Pare', 'Shi Yomi', 'Siang', 'Tawang',
      'Tirap', 'Upper Siang', 'Upper Subansiri', 'West Kameng', 'West Siang',
      'Capital Complex Itanagar'
    ],
    'Assam': [
      'Baksa', 'Barpeta', 'Biswanath', 'Bongaigaon', 'Cachar', 'Charaideo',
      'Chirang', 'Darrang', 'Dhemaji', 'Dhubri', 'Dibrugarh', 'Dima Hasao (North Cachar Hills)',
      'Goalpara', 'Golaghat', 'Hailakandi', 'Hojai', 'Jorhat', 'Kamrup',
      'Kamrup Metropolitan', 'Karbi Anglong', 'Karimaganj', 'Kokrajhar', 'Lakhimpur', 'Majuli',
      'Morigaon', 'Nagaon', 'Nalbari', 'Sivasagar', 'Sonitpur', 'South Salamara Mankachar',
      'Tinsukia', 'Udakguri', 'West Karbi Anglong', 'Bajali', 'Tamulpur'
    ],
    'Bihar': [
      'Araria', 'Arwal', 'Aurangabad', 'Banka', 'Begusarai', 'Bhagalpur',
      'Bhojpur', 'Buxar', 'Darbhanga', 'East Champaran (Motihari', 'Gaya', 'Gopalganj',
      'Jamui', 'Jehanabad', 'Kaimur (Bhabua)', 'Katihar', 'Khagaria', 'Kishanganj',
      'Lakhisarai', 'Madhepura', 'Madhubani', 'Munger (Monghyr)', 'Muzaffarpur', 'Nalanda',
      'Nawada', 'Patna', 'Purnia (Purnea)', 'Rohtas', 'Saharasa', 'Samastipur',
      'Saran', 'Sheikhpura', 'Sheohar', 'Sitamarhi', 'Siwan', 'Supaul',
      'Vaishali', 'West Champaran'
    ],
    'Chhattisgarh': [
      'Balod', 'Baloda Bazar', 'Balrampur', 'Bastar', 'Bemetara', 'Bijapur',
      'Bilaspur', 'Dantewada (South Bastar)', 'Dhamtari', 'Durg', 'Gariyaband', 'Janjigir-Champa',
      'Jashpur', 'Kabirdham (Kawardha)', 'Kanker (North Bastar)', 'Kondagaon', 'Korba', 'Korea (Koriya)',
      'Mahasamund', 'Mungeli', 'Narayanpur', 'Raigarh', 'Raipur', 'Rajnandgaon',
      'Sukma', 'Surajpur', 'Surguja', 'Gaurela-Pendra-Marwahi', 'Khairagarh-Chhuikhadan-Gandai', 'Manendragarh-Chirmiri-Bharatpur',
      'Mohla-Manpur-Chowki', 'Sarangarh-Bilaigarh', 'Shakti'
    ],
    'Goa': [
      'North Goa', 'South Goa'
    ],
    'Gujarat': [
      'Ahmedabad', 'Amreli', 'Anand', 'Arvalli', 'Banaskantha (Palanpur)',
      'Bharuch', 'Bhavnagar', 'Botad', 'Chhota Udepur', 'Dahod',
      'Dangs (Ahwa)', 'Devbhoomi Dwarka', 'Gandhinagar', 'Gir Somnath', 'Jamnagar',
      'Junagadh', 'Kachchh', 'Kheda (Nadiad)', 'Mahisagar', 'Mehsana',
      'Morbi', 'Narmada (Rajpipla)', 'Navsari', 'Panchmahal (Godhra)', 'Patan',
      'Porbandar', 'Rajkot', 'Sabarkantha (Himmatnagar)', 'Surat', 'Surendranagar',
      'Tapi (Vyara)', 'Vadodara', 'Valsad'
    ],
    'Haryana': [
      'Ambala', 'Bhiwani', 'Charkhi Dadri', 'Faridabad', 'Gurgaon',
      'Hisar', 'Jhajjar', 'Jind', 'Kaithal', 'Karnal',
      'Kurukshetra', 'Mahendragarh', 'Nuh', 'Palwal', 'Panchkula',
      'Panjpat', 'Rohtak', 'Sirsa', 'Sonipat', 'Yamunanagar',
      'Fatehabad', 'Rewari'
    ],
    'Himachal Pradesh': [
      'Bilaspur', 'Chamba', 'Hamirpur', 'Kangra',
      'Kinnaur', 'Kullu', 'Lahaul & Spiti', 'Mandi',
      'Shimla', 'Sirmaur', 'Solan', 'Una'
    ],
    'Jharkhand': [
      'Bokaro', 'Chatra', 'Deoghar', 'Dhanbad', 'Dumka', 'East Singhbhum',
      'Garhwa', 'Giridih', 'Godda', 'Gumla', 'Hazaribag', 'Jamtara',
      'Khunti', 'Koderma', 'Latehar', 'Lohardaga', 'Pakur', 'Palamu',
      'Ramgarh', 'Ranchi', 'Sahibganj', 'Seraikela-Kharsawan', 'Simdega', 'West Singhbhum'
    ],
    'Karnataka': [
      'Bagalkot', 'Bellari (Bellary)', 'Belagavi (Begaum)', 'Bengaluru (Bangalore) Rural', 'Bengaluru (Bangalore) Urban', 'Bidar',
      'Chamarajanagar', 'Chikballapur', 'Chikkamagaluru (Chikmagalur)', 'Dakshina Kannada', 'Davangere', 'Dharwad',
      'Gadag', 'Hassan', 'Haveri', 'Kalaburagi (Gulbaraga)', 'Kodagu', 'Kolar',
      'Koppal', 'Mandya', 'Mysuru (Mysore)', 'Raichur', 'Ramanagara', 'Shivamogga (Shimoga)',
      'Tumakuru (Tumkur)', 'Udupi', 'Uttara Kannada (Karwar)', 'Vijayapura (Bijapur)', 'Yadgir', 'Chitradurga',
      'Vijayanagara'
    ],
    'Kerala': [
      'Alappuzha', 'Ernakulam', 'Idukki', 'Kannur',
      'Kasaragod', 'Kollam', 'Kottayam', 'Kozhikode',
      'Malappuram', 'Palakkad', 'Pathanamthitta', 'Thiruvananthapuram',
      'Thrissur', 'Wayanad'
    ],
    'Madhya Pradesh': [
      'Agar Malwa', 'Alirajpur', 'Anuppur', 'Ashoknagar', 'Balaghat', 'Barwani',
      'Betul', 'Bhind', 'Bhopal', 'Burhanpur', 'Chhatarpur', 'Chhindwara',
      'Damoh', 'Datia', 'Dewas', 'Dhar', 'Dindori', 'Guna',
      'Gwalior', 'Harda', 'Hoshangabad', 'Indore', 'Jabalpur', 'Jhabua',
      'Katni', 'Khandwa', 'Khargone', 'Mandla', 'Mandsaur', 'Morena',
      'Narsinghpur', 'Neemuch', 'Panna', 'Raisen', 'Rajgarh', 'Ratlam',
      'Rewa', 'Sagar', 'Satna', 'Sehore', 'Seoni', 'Shahdol',
      'Shajapur', 'Sheopur', 'Shivpuri', 'Sidhi', 'Singrauli', 'Tikamgarh',
      'Ujjain', 'Umaria', 'Vidisha', 'Niwari'
    ],
    'Maharashtra': [
      'Ahmednagar', 'Akola', 'Amravati', 'Beed', 'Bhandara', 'Buldhana',
      'Chandrapur', 'Dhule', 'Gadchiroli', 'Gondia', 'Hingoli', 'Jalgaon',
      'Jalna', 'Kolhapur', 'Latur', 'Mumbai City', 'Mumbai Suburban', 'Nagpur',
      'Nanded', 'Nandurbar', 'Nashik', 'Osmanabad', 'Palghar', 'Parbhani',
      'Pune', 'Raigad', 'Ratnagiri', 'Sangli', 'Satara', 'Sindhudurg',
      'Solapur', 'Thane', 'Wardha', 'Washim', 'Yavatmal', 'Aurangabad'
    ],
    'Manipur': [
      'Bishnupur', 'Chandel', 'Churachandpur', 'Imphal East',
      'Imphal West', 'Jiribam', 'Kakching', 'Kamjong',
      'Kangpokpi', 'Noney', 'Pherzawl', 'Senapati',
      'Tamenglong', 'Tengnoupal', 'Thoubal', 'Ukhrul'
    ],
    'Meghalaya': [
      'East Garo Hills', 'East Jaintia Hills', 'East Khasi Hills', 'North Garo Hills',
      'Ri Bhoi', 'South Garo Hills', 'South West Garo Hills', 'South West Khasi Hills',
      'West Garo Hills', 'West Jaintia Hills', 'West Khasi Hills', 'Eastern West Khasi Hills'
    ],
    'Mizoram': [
      'Aizawl', 'Champhai', 'Kolasib', 'Lawngtlai', 'Hnahthial',
      'Lunglei', 'Mamit', 'Saiha', 'Serchhip', 'Khawzawl', 'Saitual'
    ],
    'Nagaland': [
      'Dimapur', 'Kiphire', 'Kohima', 'Longleng',
      'Mokokchung', 'Mon', 'Peren', 'Phek',
      'Tuensang', 'Wokha', 'Zunheboto', 'Tseminyü',
      'Chümoukedima', 'Niuland', 'Noklak', 'Shamator'
    ],
    'Odisha': [
      'Angul', 'Balangir', 'Balasore', 'Bargarh', 'Bhadrak', 'Boudh',
      'Cuttack', 'Deogarh', 'Dhenkanal', 'Gajapati', 'Ganjam', 'Jagatsinghapur',
      'Jajpur', 'Jharsuguda', 'Kalahandi', 'Kandhamal', 'Kendrapara', 'Kendujhar (Keonjhar)',
      'Khordha', 'Koraput', 'Malkangiri', 'Mayurbhanj', 'Nabarangpur', 'Nayagarh',
      'Nuapada', 'Puri', 'Rayagada', 'Sambalpur', 'Subarnapur', 'Sundargarh'
    ],
    'Punjab': [
      'Amritsar', 'Barnala', 'Bathinda', 'Faridkot', 'Fatehgarh Sahib', 'Fazilka',
      'Ferozepur', 'Gurdaspur', 'Hoshiarpur', 'Jalandhar', 'Kapurthala', 'Ludhiana',
      'Mansa', 'Moga', 'Muktsar', 'Nawanshahr (Shahid Bhagat Singh Nagar)', 'Parhankot', 'Patiala',
      'Rupnagar', 'Sahibzada Ajit Singh Nagar (Mohali)', 'Sangrur', 'Tarn Taran', 'Malerkotla'
    ],
    'Rajasthan': [
      'Ajmer', 'Alwar', 'Banswara', 'Baran', 'Barmer', 'Bharatpur',
      'Bhilwara', 'Bikaner', 'Bundi', 'Chittorgarh', 'Churu', 'Dausa',
      'Dholpur', 'Dungarpur', 'Hanumangarh', 'Jaipur', 'Jaisalmer', 'Jalore',
      'Jhalawar', 'Jhunjhunu', 'Jodhpur', 'Karauli', 'Kota', 'Nagaur',
      'Pali', 'Pratapgarh', 'Rajsamand', 'Sawai Madhopur', 'Sikar', 'Sirohi',
      'Sri Ganganagar', 'Tonk', 'Udaipur'
    ],
    'Sikkim': [
      'Gangtok', 'Gyalshing', 'Pakyong',
      'Namchi', 'Mangan', 'Soreng'
    ],
    'Tamil Nadu': [
      'Ariyalur', 'Chennai', 'Coimbatore', 'Cuddalore',
      'Dharmapuri', 'Dindigul', 'Erode', 'Kanchipuram',
      'Kanyakumari', 'Karur', 'Krishnagiri', 'Madurai',
      'Nagapattinam', 'Namakkal', 'Nilgiris', 'Perambalur',
      'Pudkkottai', 'Ramanathapuram', 'Salem', 'Sivanganga',
      'Thanjavur', 'Theni', 'Thoothukundi (Tuticorin)', 'Tiruchirappalli',
      'Tirunelveli', 'Tiruppur', 'Tiruvallur', 'Tiruvannamalai',
      'Tiruvarur', 'Vellore', 'Viluppuram', 'Virdhunagar',
      'Tenkasi', 'Tirupattur', 'Ranipet', 'Chengalpet',
      'Kallakurichi', 'Mayiladuthurai'
    ],
    'Telangana': [
      'Adilabad', 'Bhadradri Kothagudem', 'Hyderabad', 'Jagital',
      'Jangaon', 'Jayashankar Bhoopalpally', 'Jogulamba Gadwal', 'Kamareddy',
      'Karimnagar', 'Khammam', 'Komaram Bheem Asifabad', 'Mahabubabad',
      'Mahabubnagar', 'Mancherial', 'Medak', 'Medchal-Malkajgiri',
      'Nagarkurnool', 'Nalgonda', 'Nirmal', 'Nizamabad',
      'Peddapalli', 'Rajanna Sircilla', 'Rangareddy', 'Sangareddy',
      'Siddipet', 'Suryapet', 'Vikarabad', 'Wanaparthy',
      'Warangal (Rural)', 'Hanamkonda (erstwhile Warangal (Urban))', 'Yadadri Bhuvanagiri', 'Mulugu',
      'Narayanpet'
    ],
    'Tripura': [
      'Dhalai', 'Gomati', 'Khowai', 'North Tripura',
      'Sepahijala', 'South Tripura', 'Unakoti', 'West Tripura'
    ],
    'Uttarakhand': [
      'Almora', 'Bageshwar', 'Chamoli', 'Champawat', 'Dehradun',
      'Haridwar', 'Nainital', 'Pauri Garhwal', 'Pithoragarh', 'Rudraprayag',
      'Tehri Garhwal', 'Udham Singh Nagar', 'Uttarkashi'
    ],
    'Uttar Pradesh': [
      'Agra', 'Aligarh', 'Allahabad', 'Ambedkar Nagar', 'Amethi (Chatrapati sahuji Mahraj Nagar)', 'Amroha (J.P.Nagar)', 'Auraiya',
      'Azangarh', 'Baghpat', 'Bahraich', 'Ballia', 'Balrampur', 'Banda', 'Barabanki',
      'Bareilly', 'Basti', 'Bhadohi', 'Bijnor', 'Budaun', 'Bulandshahr', 'Chandauli',
      'Chitrakoot', 'Deoria', 'Etah', 'Etawah', 'Faizabad', 'Farrukhabad', 'Fatehpur',
      'Firozabad', 'Gautam Buddha Nagar', 'Ghaziabad', 'Ghazipur', 'Gonda', 'Gorakhpur', 'Hamirpur',
      'Hapur (Panchsheel Nagar)', 'Hardoi', 'Hathras', 'Jalaun', 'Jaunpur', 'Jhansi', 'Kannauj',
      'Kanpur Dehat', 'Kanpur Nagar', 'Kanshiram Nagar (Kasganj)', 'Kaushambi', 'Kushinagar (Padrauna)', 'Lakhimpur - Kheri', 'Lalitpur',
      'Lucknow', 'Maharajganj', 'Mahoba', 'Mainpuri', 'Mathura', 'Mau', 'Meerut',
      'Mizapur', 'Moradabad', 'Muzaffarnagar', 'Pilibhit', 'Pratapgarh', 'RaeBareli', 'Rampur',
      'Saharanpur', 'Sambhal (Bhim Nagar)', 'Sant Kabir Nagar', 'Shahjahanpur', 'Shamali (Prabuddh Nagar)', 'Shravasti', 'Siddharth Nagar',
      'Sitapur', 'Sonbhandra', 'Sultanpur', 'Unnao', 'Varanasi'
    ],
    'West Bengal': [
      'Alipurduar', 'Bankura', 'Birbhum', 'Cooch Behar', 'Dakshin Dinajpur (South Dinajpur)', 'Darjeeling',
      'Hooghly', 'Howrah', 'Jalpaiguri', 'Jhargram', 'Kalimpong', 'Kolkata',
      'Malda', 'Murshidabad', 'Nadia', 'North 24 Parganas', 'Paschim Medinipur (West Medinipur)', 'Paschim (West) Burdwan (Bardhaman)',
      'Purba Burdwan (Bardhaman)', 'Purba Medinipur (East Medinipur)', 'Purulia', 'South 24 Parganas', 'Uttar Dinajpur (North Dinajpur)'
    ],
    'Andaman and Nicobar Island': [
      'Nicobar', 'North and Middle Andaman', 'South Andaman'
    ],
    'Chandigarh': [
      'Chandigarh'
    ],
    'Dadra and Nagar Haveli and Daman and Diu': [
      'Dadra And Nagar Haveli', 'Daman', 'Diu'
    ],
    'Delhi': [
      'Central Delhi', 'East Delhi', 'New Delhi', 'North Delhi',
      'North East Delhi', 'North West Delhi', 'Shahdara', 'South Delhi',
      'South East Delhi', 'South West Delhi', 'West Delhi'
    ],
    'Jammu and Kashmir': [
      'Anantnag', 'Bandipore', 'Baramulla', 'Budgam', 'Doda',
      'Ganderbal', 'Jammu', 'Kathua', 'Kishtwar', 'Kulgam',
      'Kupwara', 'Poonch', 'Pulwama', 'Rajouri', 'Ramban',
      'Reasi', 'Samba', 'Shopian', 'Srinagar', 'Udhampur'
    ],
    'Ladakh': [
      'Kargil', 'Leh', 'Zanskar', 'Drass', 'Sham', 'Nubra', 'Changthang'
    ],
    'Lakshadweep': [
      'Lakshadweep'
    ],
    'Puducherry': [
      'Karaikal', 'Yanam', 'Mahe', 'Pondicherry'
    ]
  };

  List<String> get _states => _stateDistrictMap.keys.toList();
  List<String> get _districts => _selectedState != null ? _stateDistrictMap[_selectedState!] ?? [] : [];

  Future<void> _showExpertiseFilterDialog(BuildContext context) async {
    String? tempExpertise = _selectedExpertise;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectExpertise),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _expertiseOptions.map((expertise) {
              return RadioListTile<String>(
                title: Text(expertise),
                value: expertise,
                groupValue: tempExpertise,
                onChanged: (value) {
                  setState(() {
                    tempExpertise = value;
                  });
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, tempExpertise),
            child: Text(AppLocalizations.of(context)!.apply),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _selectedExpertise = result;
      });
    }
  }

  Future<void> _showLocationFilterDialog(BuildContext context) async {
    String? tempState = _selectedState;
    String? tempDistrict = _selectedDistrict;
    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.filterByLocation),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${AppLocalizations.of(context)!.state}:'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempState,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  hint: Text(AppLocalizations.of(context)!.selectState),
                  items: _states.map((state) {
                    return DropdownMenuItem<String>(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      tempState = value;
                      tempDistrict = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text('${AppLocalizations.of(context)!.district}:'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempDistrict,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  hint: Text(AppLocalizations.of(context)!.selectDistrict),
                  items: tempState != null
                      ? _stateDistrictMap[tempState]!.map((district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    );
                  }).toList()
                      : [],
                  onChanged: tempState == null
                      ? null
                      : (value) {
                    setDialogState(() {
                      tempDistrict = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, {'state': tempState, 'district': tempDistrict}),
              child: Text(AppLocalizations.of(context)!.apply),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedState = result['state'];
        _selectedDistrict = result['district'];
      });
    }
  }

  List<QueryDocumentSnapshot> _filterLawyers(List<QueryDocumentSnapshot> lawyerDocs) {
    return lawyerDocs.where((doc) {
      final lawyerData = doc.data() as Map<String, dynamic>;
      final name = lawyerData['name']?.toString().toLowerCase() ?? '';
      final expertise = lawyerData['expertise']?.toString().toLowerCase() ?? '';
      final district = lawyerData['district']?.toString().toLowerCase() ?? '';
      final state = lawyerData['state']?.toString().toLowerCase() ?? '';

      final matchesSearch = _searchQuery.isEmpty ||
          (_searchByDistrict
              ? district.contains(_searchQuery.toLowerCase())
              : name.contains(_searchQuery.toLowerCase()));

      final matchesExpertise = _selectedExpertise == null || expertise == _selectedExpertise!.toLowerCase();
      final matchesState = _selectedState == null || state == _selectedState!.toLowerCase();
      final matchesDistrict = _selectedDistrict == null || district == _selectedDistrict!.toLowerCase();

      return matchesSearch && matchesExpertise && matchesState && matchesDistrict;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.hireALawyer),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: _searchByDistrict
                          ? localizations.searchByDistrict
                          : localizations.searchByName,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(_searchByDistrict ? Icons.person : Icons.location_on),
                  tooltip: _searchByDistrict
                      ? localizations.switchToNameSearch
                      : localizations.switchToDistrictSearch,
                  onPressed: () {
                    setState(() {
                      _searchByDistrict = !_searchByDistrict;
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showExpertiseFilterDialog(context),
                    icon: const Icon(Icons.business_center, color: Colors.white),
                    label: Text(localizations.filterByExpertise, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showLocationFilterDialog(context),
                    icon: const Icon(Icons.location_city, color: Colors.white),
                    label: Text(localizations.filterByLocation, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedExpertise = null;
                        _selectedState = null;
                        _selectedDistrict = null;
                        _searchController.clear();
                        _searchByDistrict = false;
                      });
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: Text(localizations.reset, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedExpertise != null || _selectedState != null || _selectedDistrict != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_selectedExpertise != null)
                    Chip(
                      label: Text(_selectedExpertise!),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => setState(() => _selectedExpertise = null),
                    ),
                  if (_selectedState != null)
                    Chip(
                      label: Text('${localizations.state}: $_selectedState'),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => setState(() {
                        _selectedState = null;
                        _selectedDistrict = null;
                      }),
                    ),
                  if (_selectedDistrict != null)
                    Chip(
                      label: Text('${localizations.district}: $_selectedDistrict'),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => setState(() => _selectedDistrict = null),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('lawyers').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text(localizations.noLawyersAvailable));
                }

                final filteredLawyers = _filterLawyers(snapshot.data!.docs);

                if (filteredLawyers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(localizations.noMatchingLawyers, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredLawyers.length,
                  itemBuilder: (context, index) {
                    final lawyerData = filteredLawyers[index].data() as Map<String, dynamic>;
                    final String name = lawyerData['name'] ?? 'Unknown';
                    final String expertise = lawyerData['expertise'] ?? 'N/A';
                    final String experience = lawyerData['experience'] ?? 'N/A';
                    final String state = lawyerData['state'] ?? 'N/A';
                    final String district = lawyerData['district'] ?? 'N/A';
                    final String profileImageUrl = lawyerData['profileImageUrl'] ?? '';
                    final String uid = filteredLawyers[index].id;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12.0),
                        onTap: () => _showLawyerDetails(context, lawyerData, localizations, uid),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? CachedNetworkImageProvider(profileImageUrl)
                              : null,
                          child: profileImageUrl.isEmpty
                              ? const Icon(Icons.person, size: 30, color: Colors.teal)
                              : null,
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${localizations.expertise}: $expertise'),
                            Text('${localizations.experienceYears}: $experience'),
                            Text('${localizations.location}: $district, $state'),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.teal),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLawyerDetails(BuildContext context, Map<String, dynamic> lawyerData, AppLocalizations localizations, String uid) {
    final String name = lawyerData['name'] ?? 'Unknown';
    final String expertise = lawyerData['expertise'] ?? 'N/A';
    final String experience = lawyerData['experience'] ?? 'N/A';
    final String bio = lawyerData['bio'] ?? 'No bio available.';
    final String email = lawyerData['email'] ?? 'N/A';
    final String state = lawyerData['state'] ?? 'N/A';
    final String district = lawyerData['district'] ?? 'N/A';
    final String profileImageUrl = lawyerData['profileImageUrl'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? CachedNetworkImageProvider(profileImageUrl)
                        : null,
                    child: profileImageUrl.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.teal)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        const SizedBox(height: 4),
                        Text(expertise, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(child: Text('$district, $state', style: TextStyle(color: Colors.grey[600]))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _detailItem(Icons.email, '${localizations.email}: $email'),
              _detailItem(Icons.work, '${localizations.experienceYears}: $experience'),
              const Divider(height: 32),
              Text(
                localizations.bio,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 8),
              Text(bio, style: const TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.chatComingSoon),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Chat', style: const TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}