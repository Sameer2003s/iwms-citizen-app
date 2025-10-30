// lib/core/api_config.dart

// ⚠️ SECURITY WARNING: 
// 
// THIS FILE SHOULD BE ADDED TO YOUR .gitignore TO PREVENT COMMITTING SECRETS.
// For production, use a secure method like flutter_dotenv or build flavors.

// Base URL (without query params)
const String kVehicleApiBaseUrl = "https://api.vamosys.com/mobile/getGrpDataForTrustedClients";

// API Parameters (ZIGMA specific credentials - THESE MUST BE PROTECTED!)
const String kProviderName = "ZIGMA";
const String kFCode = "VAM";