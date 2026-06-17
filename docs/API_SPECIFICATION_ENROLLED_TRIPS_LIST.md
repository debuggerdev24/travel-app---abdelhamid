# API Specification: Get All Enrolled/Booked Trips

## Overview
This API endpoint returns a list of all enrolled/booked trips for the authenticated user. This is used in the Trip tab to display "My Booked Trips".

## Endpoint
```
GET /api/user-payment/my-trips
```

## Authentication
- Requires valid user authentication token (JWT)
- Authorization header: `Bearer <token>`

## Request Parameters
None (uses authenticated user context)

## Response Format

### Success Response
**Status Code:** `200 OK`

**Response Body:**
```json
{
  "status": 1,
  "message": "Enrolled trips fetched successfully",
  "data": [
    {
      "_id": "6a1ebcd2c5bcf409aa5f96cb",
      "tripId": "6a1ebcd2c5bcf409aa5f96cb",
      "tripName": "Test Trip 2",
      "name": "Test Trip 2",
      "location": "Makkah, Saudi Arabia",
      "bannerImage": "/uploads/bannerImage-1780399314593.png",
      "startDate": "2026-06-08T00:00:00.000Z",
      "endDate": "2026-06-24T00:00:00.000Z",
      "status": "ongoing",
      "description": "Experience the spiritual journey of a lifetime with our premium Umrah package.",
      "packages": [
        {
          "_id": "package_id_1",
          "packageName": "Premium Package",
          "roomDetails": [
            {
              "_id": "room_id_1",
              "roomType": "Double",
              "roomPrice": 2500,
              "status": "available"
            }
          ],
          "childDetails": [
            {
              "_id": "child_id_1",
              "childName": "Child (2-10 yrs)",
              "ageRange": "2-10",
              "bedAllocated": "No Bed",
              "childPrice": 1250
            }
          ],
          "inclusion": [
            "Business Class Flights",
            "5★ Hotels (Kaaba View in Makkah)",
            "VIP Transport (Private Bus)"
          ],
          "exclusion": [
            "All Meals Not Included (Buffet)",
            "Personal shopping"
          ]
        }
      ]
    },
    {
      "_id": "6a228cbd4bf273f64b6e35e9",
      "tripId": "6a228cbd4bf273f64b6e35e9",
      "tripName": "hello",
      "name": "hello",
      "location": "demo",
      "bannerImage": "/uploads/bannerImage-1780649149260.png",
      "startDate": "2026-06-08T00:00:00.000Z",
      "endDate": "2026-06-09T00:00:00.000Z",
      "status": "ongoing",
      "description": "Trip description",
      "packages": []
    }
  ]
}
```

### Error Response
**Status Code:** `404 Not Found` (if no enrolled trips)

**Response Body:**
```json
{
  "status": 0,
  "message": "No enrolled trips found",
  "data": []
}
```

**Status Code:** `401 Unauthorized`

**Response Body:**
```json
{
  "status": 0,
  "message": "Unauthorized access",
  "data": null
}
```

## Field Descriptions

### Trip Object Fields

| Field | Type | Required | Description | Example |
|-------|------|----------|-------------|---------|
| `_id` | String | Yes | Unique trip identifier | "6a1ebcd2c5bcf409aa5f96cb" |
| `tripId` | String | No | Alternative trip ID field (fallback) | "6a1ebcd2c5bcf409aa5f96cb" |
| `tripName` | String | No | Trip name (primary field used) | "Test Trip 2" |
| `name` | String | No | Alternative trip name field (fallback) | "Test Trip 2" |
| `location` | String | Yes | Trip location | "Makkah, Saudi Arabia" |
| `bannerImage` | String | Yes | Banner image path (relative to uploads folder) | "/uploads/bannerImage-1780399314593.png" |
| `startDate` | ISO 8601 Date | Yes | Trip start date | "2026-06-08T00:00:00.000Z" |
| `endDate` | ISO 8601 Date | Yes | Trip end date | "2026-06-24T00:00:00.000Z" |
| `status` | String | Yes | Trip status (ongoing, completed, upcoming, cancelled) | "ongoing" |
| `description` | String | Yes | Trip description | "Experience the spiritual journey..." |
| `packages` | Array | No | List of available packages for this trip | See Package Object below |

### Package Object Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `_id` | String | No | Package unique identifier |
| `packageName` | String | Yes | Package name/title |
| `roomDetails` | Array | Yes | List of room options |
| `childDetails` | Array | Yes | List of child pricing options |
| `inclusion` | Array/String | Yes | List of inclusions (can be array or newline-separated string) |
| `exclusion` | Array/String | Yes | List of exclusions (can be array or newline-separated string) |

### Room Detail Object Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `_id` | String | No | Room unique identifier |
| `roomType` | String | Yes | Room type (Double, Triple, Quadruple) |
| `roomPrice` | Number | Yes | Room price in EUR |
| `status` | String | Yes | Room availability status |

### Child Detail Object Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `_id` | String | No | Child option unique identifier |
| `childName` | String | Yes | Child option name |
| `ageRange` | String | Yes | Age range for child |
| `bedAllocated` | String | Yes | Whether bed is allocated (Yes/No) |
| `childPrice` | Number | Yes | Child price in EUR |

## Notes for Backend Developer

1. **Image Path**: The `bannerImage` field should return a relative path starting with `/uploads/`. The frontend will construct the full URL using the base URL.

2. **Date Format**: Dates should be in ISO 8601 format. The frontend will format them as "8 Jun – 24 Jun 2026".

3. **Field Priority**: 
   - For trip name: Use `tripName` first, fallback to `name`
   - For trip ID: Use `_id` first, fallback to `tripId`

4. **Packages**: The `packages` array is optional. If the trip has no packages, return an empty array `[]`.

5. **Inclusion/Exclusion**: These can be returned as either an array of strings or a newline-separated string. The frontend handles both formats.

6. **Status Values**: Common status values: `ongoing`, `upcoming`, `completed`, `cancelled`

7. **Empty Response**: If user has no enrolled trips, return status 0 with empty data array.

## Frontend Integration

The frontend will call this endpoint in `TripsService.loadEnrolledTripsList()` and populate the `TripProvider.enrolledTripsList` with the response data.

Current implementation uses static data (duplicate of enrolled trip) as a placeholder until this API is implemented.
