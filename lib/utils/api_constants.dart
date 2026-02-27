// lib/api/api_constants.dart

class ApiConstants {
  // Android Emulator → use 10.0.2.2
  // static const String baseUrl = "http://10.0.2.2:8080/api";

  // Real device → use your machine's local IP
  static const String baseUrl = "http://192.168.0.135:8080/api";

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static const String login   = "$baseUrl/auth/login";
  static const String signUp  = "$baseUrl/auth/signUp";
  static const String refresh = "$baseUrl/auth/refresh";

  // ─── Donations ────────────────────────────────────────────────────────────
  static const String createDonation       = "$baseUrl/donations/post";
  static const String getAllDonations       = "$baseUrl/donations";
  static const String deleteDonation        = "$baseUrl/donations/delete";
  static const String approveDonation       = "$baseUrl/donations/approve";
  static const String updateDonationStatus  = "$baseUrl/donations/status";
  static const String getPendingDonations   = "$baseUrl/donations/pending";
  static const String getApprovedDonations  = "$baseUrl/donations/approved";

  // ─── Shelters ─────────────────────────────────────────────────────────────
  static const String createShelter = "$baseUrl/shelters";
  static const String getAllShelters = "$baseUrl/shelters";
  static const String updateShelter  = "$baseUrl/shelters"; // PUT /{id}
  static const String deleteShelter  = "$baseUrl/shelters"; // DELETE /{id}

  // ─── Evacuation Routes ────────────────────────────────────────────────────
  static const String createEvacuationRoute = "$baseUrl/evacuation-routes";
  static const String getAllEvacuationRoutes = "$baseUrl/evacuation-routes";
  static const String updateEvacuationRoute  = "$baseUrl/evacuation-routes";
  static const String deleteEvacuationRoute  = "$baseUrl/evacuation-routes";

  // ─── Payments ─────────────────────────────────────────────────────────────
  static const String createPayment = "$baseUrl/payments";
  static const String getAllPayments = "$baseUrl/payments";

  // ─── Videos ───────────────────────────────────────────────────────────────
  static const String uploadVideo       = "$baseUrl/videos";
  static const String getAllVideos       = "$baseUrl/videos";
  static const String getApprovedVideos = "$baseUrl/videos/approved";
  static const String approveVideo      = "$baseUrl/videos";
  static const String deleteVideo       = "$baseUrl/videos";

  // ─── Volunteer Reports ────────────────────────────────────────────────────
  static const String createReport          = "$baseUrl/reports";
  static const String getAllReports          = "$baseUrl/reports";
  static const String getReportsByVolunteer  = "$baseUrl/reports/volunteer";

  // ─── Issues ───────────────────────────────────────────────────────────────
  static const String createIssue = "$baseUrl/issues";
  static const String getAllIssues = "$baseUrl/issues";
  static const String deleteIssue  = "$baseUrl/issues";

  // ─── Products ─────────────────────────────────────────────────────────────
  static const String createProduct = "$baseUrl/products";
  static const String getAllProducts = "$baseUrl/products";
  static const String updateProduct  = "$baseUrl/products";
  static const String deleteProduct  = "$baseUrl/products";

  // ─── Group Tasks ──────────────────────────────────────────────────────────
  static const String createGroupTask      = "$baseUrl/group-tasks";
  static const String getAllGroupTasks      = "$baseUrl/group-tasks";
  static const String getGroupTasksByPlace  = "$baseUrl/group-tasks/place";
  static const String deleteGroupTask       = "$baseUrl/group-tasks";

  // ─── Missing Persons ──────────────────────────────────────────────────────
  static const String createMissingPerson = "$baseUrl/missing-persons/post";
  static const String getAllMissingPersons = "$baseUrl/missing-persons";
  static const String updateMissingPerson  = "$baseUrl/missing-persons/update";
  static const String deleteMissingPerson  = "$baseUrl/missing-persons/delete";

  // ─── Blood Requests ───────────────────────────────────────────────────────
  static const String createBloodRequest = "$baseUrl/blood-requests/post";
  static const String getAllBloodRequests = "$baseUrl/blood-requests";
  static const String deleteBloodRequest  = "$baseUrl/blood-requests/delete";
}