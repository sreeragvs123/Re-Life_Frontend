class ApiConstants {
  // Android Emulator
  // static const String baseUrl = "http://10.0.2.2:8080/api";

  // REAL DEVICE (your phone)
  static const String baseUrl = "http://192.168.0.135:8080/api";

  // ─── Donation Endpoints ───────────────────────────────────────────────────
  static const String createDonation       = "$baseUrl/donations/post";
  static const String getAllDonations      = "$baseUrl/donations";
  static const String deleteDonation       = "$baseUrl/donations/delete";
  static const String approveDonation      = "$baseUrl/donations/approve";
  static const String updateDonationStatus = "$baseUrl/donations/status";
  static const String getPendingDonations  = "$baseUrl/donations/pending";
  static const String getApprovedDonations = "$baseUrl/donations/approved";

  // ─── Shelter Endpoints ────────────────────────────────────────────────────
  static const String createShelter = "$baseUrl/shelters";
  static const String getAllShelters = "$baseUrl/shelters";
  static const String updateShelter  = "$baseUrl/shelters"; // PUT /{id}
  static const String deleteShelter  = "$baseUrl/shelters"; // DELETE /{id}

  // ─── Evacuation Route Endpoints ───────────────────────────────────────────
  static const String createEvacuationRoute = "$baseUrl/evacuation-routes";
  static const String getAllEvacuationRoutes = "$baseUrl/evacuation-routes";
  static const String updateEvacuationRoute  = "$baseUrl/evacuation-routes"; // PUT /{id}
  static const String deleteEvacuationRoute  = "$baseUrl/evacuation-routes"; // DELETE /{id}

  // ─── Payment Endpoints ────────────────────────────────────────────────────
  static const String createPayment = "$baseUrl/payments";
  static const String getAllPayments = "$baseUrl/payments";

  // ─── Video Endpoints ──────────────────────────────────────────────────────
  static const String uploadVideo       = "$baseUrl/videos";          // POST multipart
  static const String getAllVideos      = "$baseUrl/videos";          // GET — Admin
  static const String getApprovedVideos = "$baseUrl/videos/approved"; // GET — User/Volunteer
  static const String approveVideo      = "$baseUrl/videos";          // PUT /{id}/approve
  static const String deleteVideo       = "$baseUrl/videos";          // DELETE /{id}
}