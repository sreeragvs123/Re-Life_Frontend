class ApiConstants {
  // Android Emulator
  // static const String baseUrl = "http://10.0.2.2:8080/api";

  // REAL DEVICE (your phone)
  static const String baseUrl = "http://192.168.0.136:8080/api";


  static const String donationsBase = '/donations';
  static const String createDonation = '$donationsBase/post';
  static const String getAllDonations = donationsBase;
  static const String deleteDonation = '$donationsBase/delete';
  static const String approveDonation = '$donationsBase/approve'; // Will add to backend
  static const String updateDonationStatus = '$donationsBase/status'; // Will add to backend
  static const String getPendingDonations = '$donationsBase/pending'; // Will add to backend
  static const String getApprovedDonations = '$donationsBase/approved'; // Will add to backend
}
