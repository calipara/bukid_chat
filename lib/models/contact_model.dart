class AgricultureOfficerModel {
  final String name;
  final String position;
  final String organization;
  final String phoneNumber;
  final String email;
  final String address;
  final String municipality;

  AgricultureOfficerModel({
    required this.name,
    required this.position,
    required this.organization,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.municipality,
  });
}

// Sample data for municipal agriculture officers
class ContactData {
  static List<AgricultureOfficerModel> getMunicipalOfficers() {
    return [
      AgricultureOfficerModel(
        name: 'Engr. Ricardo Santos',
        position: 'Municipal Agriculturist',
        organization: 'Municipal Agriculture Office - Nueva Ecija',
        phoneNumber: '0917-123-4567',
        email: 'ricardo.santos@negovph.com',
        address: 'Municipal Agriculture Office, Nueva Ecija',
        municipality: 'Nueva Ecija',
      ),
      AgricultureOfficerModel(
        name: 'Dr. Maria Reyes',
        position: 'Agricultural Extension Worker',
        organization: 'Municipal Agriculture Office - Isabela',
        phoneNumber: '0918-765-4321',
        email: 'maria.reyes@isabelagovph.com',
        address: 'Municipal Agriculture Office, Isabela',
        municipality: 'Isabela',
      ),
      AgricultureOfficerModel(
        name: 'Engr. Juan Dela Cruz',
        position: 'Rice Program Coordinator',
        organization: 'Department of Agriculture - Region III',
        phoneNumber: '0919-876-5432',
        email: 'juan.delacruz@da.gov.ph',
        address: 'Regional Agriculture Office, San Fernando, Pampanga',
        municipality: 'Region III',
      ),
      AgricultureOfficerModel(
        name: 'Dr. Ana Magbanua',
        position: 'Corn Program Specialist',
        organization: 'Department of Agriculture - Region II',
        phoneNumber: '0926-543-2109',
        email: 'ana.magbanua@da.gov.ph',
        address: 'Regional Agriculture Office, Tuguegarao City',
        municipality: 'Region II',
      ),
    ];
  }
}