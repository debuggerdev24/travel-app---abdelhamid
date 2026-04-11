/// Preset durations for live location sharing.
///
/// Keep in sync with [travel-admin-backend/helpers/constants.js]
/// `LIVE_LOCATION_DURATION_OPTIONS_MINUTES`.
const List<int> kLiveLocationDurationOptionsMinutes = [15, 60, 480];

String liveLocationDurationTitle(int minutes) {
  switch (minutes) {
    case 15:
      return '15 minutes';
    case 60:
      return '1 hour';
    case 480:
      return '8 hours';
    default:
      return '$minutes minutes';
  }
}

String liveLocationDurationSubtitle(int minutes) {
  switch (minutes) {
    case 15:
      return 'Short live share';
    case 60:
      return 'Default-style session';
    case 480:
      return 'Longest preset (until you stop or time ends)';
    default:
      return 'Live location';
  }
}
