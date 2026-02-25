class ApiConstants {
  // Android Emulator
  // static const String baseUrl = "http://10.0.2.2:8080/api";

  // REAL DEVICE (your phone)
  static const String baseUrl = "http://192.168.0.135:8080/api";


  static const String donationsBase = '/donations';
  static const String createDonation = '$donationsBase/post';
  static const String getAllDonations = donationsBase;
  static const String deleteDonation = '$donationsBase/delete';
  static const String approveDonation = '$donationsBase/approve'; // Will add to backend
  static const String updateDonationStatus = '$donationsBase/status'; // Will add to backend
  static const String getPendingDonations = '$donationsBase/pending'; // Will add to backend
  static const String getApprovedDonations = '$donationsBase/approved'; // Will add to backend



    // ─── Shelter Endpoints ────────────────────────────────────────────────────
  static const String createShelter  = "$baseUrl/shelters";
  static const String getAllShelters  = "$baseUrl/shelters";
  static const String updateShelter  = "$baseUrl/shelters"; // PUT /{id}
  static const String deleteShelter  = "$baseUrl/shelters"; // DELETE /{id}

  // ─── Evacuation Route Endpoints ───────────────────────────────────────────
  static const String createEvacuationRoute  = "$baseUrl/evacuation-routes";
  static const String getAllEvacuationRoutes  = "$baseUrl/evacuation-routes";
  static const String updateEvacuationRoute  = "$baseUrl/evacuation-routes"; // PUT /{id}
  static const String deleteEvacuationRoute  = "$baseUrl/evacuation-routes";
  
}
