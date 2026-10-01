# Temheed — deliverable flows and test cases

Use this document to walk the built app and compare it with the intended delivery. Each flow is the path a real user takes. Under every step is what must happen, then the edge cases that must not break that step.

A separate requirements file was not attached. These flows follow the mobile app as it is built today. The admin section is the matching back-office path, because this repo is the mobile app only.

How to mark a run:

| Result | When to use it |
| --- | --- |
| Pass | The screen matches the “Must happen” line. |
| Fail | Anything different: wrong screen, missing data, crash, or a second unwanted API call. Attach a screenshot and the API status. |
| Blocked | You cannot run it because a previous step or test data is missing. |

Priority: **High** must pass before client delivery. **Medium** should pass. **Low** is polish.

Cover one Android phone, one iPhone, and one slow network. Repeat the happy paths once in English and once in Arabic, French, or Dutch.

---

## Flow A — First launch and sign in

**Goal:** A new or logged-out traveller reaches Home with a saved session.

| Step | Screen | What you do | Must happen | Case id |
| --- | --- | --- | --- | --- |
| A1 | App icon | Open the app with no saved token. | Sign-in screen. No crash, no Home flash. | MOB-SES-02 |
| A2 | Sign in | Leave fields empty and submit. | Each required field shows an error. No login API call. | MOB-AUTH-02 |
| A3 | Sign in | Enter a wrong password for a real traveller code. | Error toast. You stay on Sign in. No token is saved. | MOB-AUTH-03 |
| A4 | Sign in | Enter a valid traveller code, email or phone, and password. | `POST /api/user/auth/login` succeeds. Access token, refresh token, and user id are saved. Home tab opens. | MOB-AUTH-01 |
| A5 | Home | Kill the app and open it again. | Home opens directly. Sign in is not shown. | MOB-SES-01 |
| A6 | Profile | Logout → Yes. | Tokens are cleared. Sign in opens. System back does not return to Home. | MOB-AUTH-15 |

**Edge cases on this flow**

| ID | Priority | Where | What you do | Must happen |
| --- | --- | --- | --- | --- |
| MOB-AUTH-04 | High | A4 | Unknown traveller code or email. | Clear error. No crash. No token saved. |
| MOB-AUTH-05 | Medium | A4 | Toggle the password eye. | Password shows and hides. The typed value stays the same. |
| MOB-AUTH-16 | Medium | A6 | Logout → Cancel. | You stay on Profile. The session remains. |
| MOB-SES-07 | Medium | A4 | Watch the login request headers. | Login does not send `Authorization: Bearer` from an old session. |
| MOB-AUTH-17 | Medium | A4 | Sign in as a guide account, if the backend marks that role. | Guide dashboard opens, not the traveller tabs. |

---

## Flow B — Create account and reset password

**Goal:** A new user can register, and an existing user can replace a forgotten password.

| Step | Screen | What you do | Must happen | Case id |
| --- | --- | --- | --- | --- |
| B1 | Sign in | Open Sign up. | Registration form opens. | MOB-AUTH-06 |
| B2 | Sign up | Submit a new email, phone, and valid password. | Account is created. You continue to OTP or Sign in, as the screen is built. | MOB-AUTH-06 |
| B3 | Sign in | Open Forgot password. Enter the registered email. | OTP screen opens. | MOB-AUTH-08 |
| B4 | OTP | Enter the correct code. | Reset-password screen opens. | MOB-AUTH-10 |
| B5 | Reset password | Set a new valid password. | Success. Sign in with the new password works. The old password fails. | MOB-AUTH-13 |

**Edge cases on this flow**

| ID | Priority | Where | What you do | Must happen |
| --- | --- | --- | --- | --- |
| MOB-AUTH-07 | High | B2 | Register an email or phone that already exists. | API error. A second account is not created in the UI. |
| MOB-AUTH-09 | High | B3 | Email that is not registered. | Error. You are not sent to OTP. |
| MOB-AUTH-11 | High | B4 | Wrong OTP, then an expired OTP. | Error. Password is not changed. |
| MOB-AUTH-12 | Medium | B4 | Tap Resend when the timer allows it. | A new OTP arrives. The previous OTP stops working. |
| MOB-AUTH-14 | Medium | B5 | Too-short password, or confirm password does not match. | Submit is blocked. |

---

## Flow C — Home: see trips and open one

**Goal:** After login, the traveller sees only their trips and can open one.

The logo bar (logo, profile photo, notification icon) stays fixed. Everything under it scrolls: “My Trip”, Next Prayer, Current/Past, and the cards.

| Step | Screen | What you do | Must happen | Case id |
| --- | --- | --- | --- | --- |
| C1 | Home | Land on Home after login. | “My Trip” title, Next Prayer row, Current tab selected, trip cards for upcoming trips. | MOB-HOME-02 |
| C2 | Home | Scroll down. | Logo bar does not move. Title, prayer, tabs, and cards move together. | MOB-HOME-01 |
| C3 | Home | Read one card. | Image, title, location, date range, and status match the trips API. | MOB-HOME-02 |
| C4 | Home | Tap Past. | The white pill moves onto Past. Only past trips show. | MOB-HOME-03 |
| C5 | Home | Tap Current again. | Upcoming trips return. | MOB-HOME-03 |
| C6 | Home | Tap a trip card. | Trip Details opens for that trip only. | MOB-HOME-06 |
| C7 | Trip details | Tap back. | You return to Home on the same tab you left. | MOB-BOOK-01 |

**Edge cases on this flow**

| ID | Priority | Where | What you do | Must happen |
| --- | --- | --- | --- | --- |
| MOB-HOME-04 | High | C1 or C4 | Account with no trips on that tab. | Empty state: icon, “No Current Trips” or “No Past Trips”, and a short subtitle. Pull to refresh still works. |
| MOB-HOME-05 | Medium | C1 | Slow network. | Card-shaped shimmer (image, title, location, date, status). Prayer row uses a shimmer line, not a tiny spinner that collapses the row. |
| MOB-HOME-07 | High | C1 | Wait and read Next Prayer. | Name, time, and countdown match the prayer API. Tap opens Prayer Times. Coming back refreshes the chip. |
| MOB-HOME-08 | Medium | C1 | Prayer API fails. | Trips still show. Home does not crash. |
| MOB-HOME-09 | Medium | C2 | Pull to refresh. | Trips and prayer times reload. The selected tab does not change by itself. |
| MOB-HOME-10 | Medium | C1 | User has a profile photo. | Header avatar loads. Shimmer while it loads. A broken URL shows the fallback avatar. |
| MOB-HOME-11 | Medium | C1 | Tap the notification icon. | Notification list opens. |
| MOB-HOME-12 | Low | C3 | Trip image URL is empty or 404. | Title, location, date, and status still show. |

---

## Flow D — Book a trip and pay

**Goal:** From a trip card, the traveller selects a package, room, main booker, family member, reviews the cost, and pays. The booking is written to the server only after payment succeeds.

This is the main delivery path. Walk it once with a Stripe test card that succeeds, and once with a card that fails.

| Step | Screen | What you do | Must happen | Case id |
| --- | --- | --- | --- | --- |
| D1 | Trip details | Open an upcoming trip from Home. | Photo, title, location, dates, About Us, and package cards. | MOB-BOOK-01 |
| D2 | Trip details | Tap Read more on a package. | Room options, and when present child prices, inclusions, and exclusions. Read less collapses them. | MOB-BOOK-03 |
| D3 | Trip details | Tap the package, then Select Package & Room Type. | Room Details opens for that package. | MOB-BOOK-05 |
| D4 | Room details | Leave room type or bed type empty. Tap Next. | Toast: “Please fill the required details”. You stay on Room Details. | MOB-BOOK-06 |
| D5 | Room details | Fill person count (minimum 1), room type, and bed type. Set child and baby only if you need them. Tap Next. | Choices are stored on the phone. Person Details opens. `save-room-preference` is not called yet. | MOB-BOOK-07 |
| D6 | Person Details | Submit with a required field empty. | Field error. You do not go forward. | MOB-BOOK-09 |
| D7 | Person Details | Fill the main booker. Tap Add Second Person Details. | Values are kept locally. Surviving Family Members opens. | MOB-BOOK-09 |
| D8 | Family members | Look at the form before typing. | First name, surname, phone, and relationship are empty. A previous visit’s text is not shown. | MOB-BOOK-11 |
| D9 | Family members | Fill the four fields. Tap Done & Next. | Those four values are kept for the later add-family-member call. Package Summary opens. | MOB-BOOK-12 |
| D10 | Package summary | Read the summary. | Package name, room, people, and total match what you entered. Total is in euros. | MOB-BOOK-14 |
| D11 | Package summary | Tap Book Now. | Payment options open. Nothing is charged yet. | MOB-PAY-01 |
| D12 | Payment | Tap Confirm & Pay Now and complete a successful test card. | Stripe succeeds. Then the app saves, in order: booking package, room preference, person details, family member. Success screen: “Your trip is now confirmed”. | MOB-PAY-01 |
| D13 | Success | Tap Back to My Trip. | Trip tab opens (the second bottom tab). The new trip is in My Trips with Payment: paid, after refresh if needed. | MOB-PAY-07 |

**Edge cases on this flow**

| ID | Priority | Where | What you do | Must happen |
| --- | --- | --- | --- | --- |
| MOB-BOOK-02 | Medium | D1 | Slow network on Trip Details. | Shimmer matches the photo, title, location, dates, About Us lines, and package card. Back still works. |
| MOB-BOOK-04 | High | D1 | Trip with no packages. | “No packages available for this trip.” You cannot open a broken room form. |
| MOB-BOOK-08 | Medium | D3 | Booking that already has a saved room preference. | Fields are read-only. Button says Continue to Personal Details. Empty fields stay empty. They are not filled with “With Bed” or “Auto Filled”. |
| MOB-BOOK-10 | Medium | D7 | Profile already has name, phone, and email. | Those empty fields are prefilled. Text you already typed is not overwritten. |
| MOB-BOOK-13 | High | D9 | Family first name empty, or relationship shorter than 2 characters. | Field error. Summary does not open. |
| MOB-BOOK-15 | High | D7 or D10 | System back. | Dialog: “Discard unsaved data?” Cancel stays. Discard clears the local booking and goes back. |
| MOB-BOOK-16 | Medium | Home Past | Open a past trip instead of an upcoming one. | Status, payment summary, and support contact. The new-booking button is not shown. |
| MOB-PAY-02 | High | D12 | Declined Stripe test card. | Failed screen or error. User is not paid. Admin must not show a paid booking. |
| MOB-PAY-03 | High | D12 | Open the payment sheet, then close it. | Not marked paid. Book Now can be used again. No second paid booking is created. |
| MOB-GEN-04 | Medium | D5, D7, D12 | Double tap Next, Add Second Person, or Pay. | One submit only. |
| MOB-BOOK-17 | Medium | Past trip | Share on Review, send a rating, return. | Review is stored. The button label changes after success. |

**What is saved, and when**

| Moment | Saved on the server? |
| --- | --- |
| Next on Room Details | No. Kept on the phone. |
| Add Second Person Details | No. Kept on the phone. |
| Done & Next on family | No. Kept on the phone. |
| Payment success | Yes. Package booking, room preference, person, and family member. |
| Payment fail or cancel | No paid booking. |

---

## Flow E — Use a booked trip

**Goal:** After payment, the traveller can see the trip and its practical information.

| Step | Screen | What you do | Must happen | Case id |
| --- | --- | --- | --- | --- |
| E1 | Trip tab | Open the Trip tab. | “My Trips” and one card per enrolled booking: image, code, location, dates, payment chip. | MOB-TRIP-01 |
| E2 | My Trips | Tap the card you just paid. | Trip tools open for that booking only. | MOB-TRIP-04 |
| E3 | Trip tools | Open Payment. | Amount and status match the payment. | MOB-TRIP-05 |
| E4 | Trip tools | Open Flights. | Rows match the flights API. | MOB-TRIP-06 |
| E5 | Trip tools | Open Hotels. | Name, address, phone, check-in, check-out, rooms, guests. | MOB-TRIP-07 |
| E6 | Trip tools | Open Itinerary. | Steps for the trip, in API order. | MOB-TRIP-09 |
| E7 | Trip tools | Open Essentials, then each item. | Packing List, Currency & Money, Emergency Contacts, Local Info, Health & Safety, Umrah Guide, Dua List. Each shows its own API data. | MOB-TRIP-10 |
| E8 | Trip tools | Open Documents. | Passport & visa, tickets, medical, hotel vouchers, travel documents that exist for this booking. | MOB-TRIP-12 |
| E9 | Documents | Add a photo with type and name. | Upload succeeds. The list refreshes and shows the file. | MOB-TRIP-13 |
| E10 | My Trips | Tap the offline icon. | Toast: “Trip saved for offline access”. | MOB-TRIP-16 |
| E11 | Offline | Turn on airplane mode. Open Offline Access. | The saved trip can be read. Trips you did not save are absent. | MOB-TRIP-17 |

**Edge cases on this flow**

| ID | Priority | Where | What you do | Must happen |
| --- | --- | --- | --- | --- |
| MOB-TRIP-02 | Medium | E1 | Slow network. | Card shimmer under the My Trips title. The title stays visible. |
| MOB-TRIP-03 | High | E1 | Account with no booking. | Empty state. No fake trip. |
| MOB-TRIP-08 | Medium | E5 | Hotel API fails. | “Failed to load hotel details” and Retry. Retry loads the hotel. |
| MOB-TRIP-09 | High | E6 | Itinerary API fails. | Error and Retry. Retry loads the steps. |
| MOB-TRIP-11 | Medium | E7 | Currency converter: enter an amount, then a blank or zero. | A valid amount converts with the API rate. Invalid input is blocked. |
| MOB-TRIP-14 | High | E9 | Submit a document with no photo or no name. | Upload does not start. |
| MOB-TRIP-15 | Medium | E8 | Open a saved image, then a broken URL. | Good file opens. Broken URL shows an error, not a freeze. |
| MOB-TRIP-18 | Medium | E5 / documents | Hotel voucher and travel insurance screens. | They match the booking. Empty content uses the empty state. |
| MOB-PAY-04 | High | Profile or trip payment | Open payment history. | Rows match the backend: amount, status, date. |
| MOB-PAY-05 | Medium | History | Open one receipt. | Receipt matches that payment id. |
| MOB-PAY-06 | Medium | History | User with no payments. | Empty state. No crash. |

Essentials empty rule: if the API list is empty, the screen shows the empty state (icon, title, subtitle). It must not show a blank page or sample names.

---

## Flow F — Chat

**Goal:** The traveller sees trip conversations and can send a message.

| Step | Screen | What you do | Must happen | Case id |
| --- | --- | --- | --- | --- |
| F1 | Chat tab | Open Chat. | Title “Chat”, search icon, tabs All / Groups / Direct, then rows. | MOB-CHAT-01 |
| F2 | Chat | Read a row. | Avatar, trip name, last message, date. Unread count only when unread is greater than 0. | MOB-CHAT-01 |
| F3 | Chat | Tap Groups, then Direct, then All. | Each tab shows only that type. | MOB-CHAT-04 |
| F4 | Chat | Tap a row. | That thread opens. The correct name is in the header. | MOB-CHAT-05 |
| F5 | Thread | Send a text message. | It appears in the thread. Back on the list, that row’s preview and time update. | MOB-CHAT-06 |
| F6 | Thread | Send a photo. | The image appears in the thread and can be opened. | MOB-CHAT-07 |
| F7 | Thread | Open group info, if it is a group. | Members and shared media match the group. | MOB-CHAT-09 |

**Edge cases on this flow**

| ID | Priority | Where | What you do | Must happen |
| --- | --- | --- | --- | --- |
| MOB-CHAT-02 | Medium | F1 | Slow network. | Row shimmer (circle, name, date, message). Title and tabs stay. |
| MOB-CHAT-03 | High | F1 | Account with no chats. | Centered empty state: chat icon, “No conversations yet.”, “Your trip chats will appear here.” Pull to refresh works. |
| MOB-CHAT-08 | Medium | F5 | Airplane mode, then send. | Error. No crash. The typed text is not thrown away without a sign. |
| MOB-CHAT-10 | Low | F7 | Live location or Track travelers, if the trip uses them. | The screen loads. If location permission is denied, a clear message is shown. |

---

## Flow G — Profile, help pages, and notifications

**Goal:** Profile data matches the account, help pages load from the server, and logout ends the session.

| Step | Screen | What you do | Must happen | Case id |
| --- | --- | --- | --- | --- |
| G1 | Profile | Open the Profile tab. | Photo, personal fields, prayer, currency, language, and Help & Support. | MOB-PRO-01 |
| G2 | Profile | Tap Edit profile. Change one field. Save. | Save succeeds. Profile shows the new value when you return. | MOB-PRO-02 |
| G3 | Profile | Change the photo. | The new photo shows on Profile and on the Home header. | MOB-PRO-04 |
| G4 | Profile | Open Prayer Times, then Currency. | Prayer list matches the API. Currency opens the converter. | MOB-PRO-05 |
| G5 | Profile | Change language. Kill the app. Open it. | The chosen language is still on. | MOB-PRO-06 |
| G6 | Help | Open FAQ, Social, Terms, Privacy, Our Locations, Meet Our Team. | Each page loads its own content. Back returns to Profile. | MOB-PRO-08 |
| G7 | Help | Open Feedback. Send a rating and comment. | Success. The review is stored. | MOB-PRO-09 |
| G8 | Profile | Open App settings. Change the available option (theme). | The change applies and remains after restart. | MOB-PRO-11 |
| G9 | Home header | Tap notifications. | The list matches the notifications API. | MOB-PRO-12 |
| G10 | Notifications | Tap one item. | It is marked read. If it has a target, that screen opens. | MOB-PRO-13 |
| G11 | Profile | Logout → Yes. | Back to Flow A, step A1. | MOB-AUTH-15 |

**Edge cases on this flow**

| ID | Priority | Where | What you do | Must happen |
| --- | --- | --- | --- | --- |
| MOB-PRO-03 | High | G2 | Clear a required field, or enter a bad phone. Save. | Save is blocked or the API error is shown. The old value remains. |
| MOB-PRO-07 | Medium | G6 | FAQ from the API. Expand and collapse a question. | Answer shows and hides. An empty FAQ list shows the empty state. |
| MOB-PRO-08 | Medium | G6 | Open Social, Terms, Privacy, Locations, and Team on a fresh install. | No console error about a dirty widget. Content loads after the screen is open. |
| MOB-PRO-10 | Medium | G7 | Submit feedback with the required rating or text missing. | Submit is blocked. |
| MOB-NOT-03 | Medium | G9 | Stay logged out and check the list. | Another user’s notifications are not shown. |

---

## Flow H — Token expires while the app is open

**Goal:** A 401 does not dump the user on Sign in. The app refreshes the token and retries the call that failed.

| Step | What you do | Must happen | Case id |
| --- | --- | --- | --- |
| H1 | Use the app until the access token is expired, or replace the saved access token with an expired one. Keep the refresh token. | The next logged-in API returns 401 and message `Invalid or Expired Token`. | MOB-SES-03 |
| H2 | Watch the network log. | One `POST https://api.temheed.com/api/auth/refresh-token` with body `{ "token": "<saved refresh token>" }`. The word `user` is not in that path. | MOB-SES-05 |
| H3 | Refresh returns status 1 with `accessToken` and `refreshToken`. | Both are saved. The API from H1 is sent again once, with the new bearer token, and succeeds. You stay on the same screen. | MOB-SES-03 |
| H4 | Open Home so several APIs fail with 401 at the same time. | Only one refresh call. The other calls wait, then retry. | MOB-SES-06 |

**Edge cases on this flow**

| ID | Priority | What you do | Must happen |
| --- | --- | --- | --- |
| MOB-SES-04 | High | Refresh token missing, expired, or the refresh API returns an error. | Refresh is tried once. It does not loop. The original error is shown. The app does not navigate to Sign in by itself. |
| MOB-SES-08 | Low | Send the app to the background for several minutes, then return. | The same screen is still there. No extra Sign in. |

---

## Flow I — Admin creates data, mobile shows it

Walk these only when the admin panel is connected to the same API. Each row is one deliverable: change it in admin, then confirm it on the phone after pull-to-refresh.

| Step | Admin does this | Phone must show this | Case id |
| --- | --- | --- | --- |
| I1 | Create a traveller with email, phone, traveller code, and password. | Flow A step A4 succeeds for that user. | ADM-USER-01 |
| I2 | Change the traveller’s name, photo, and phone. | Profile and Home avatar update. Booking prefill uses the new name and phone. | ADM-USER-03 |
| I3 | Disable the user. | Sign in fails. An old access token cannot keep calling APIs. | ADM-USER-04 |
| I4 | Publish an upcoming trip with image, dates, description, and one package. | Home → Current shows the card. Trip Details shows the package and prices. | ADM-TRIP-01, ADM-TRIP-03 |
| I5 | Move that trip to past, with no booking. | It leaves Current and appears on Past. | ADM-TRIP-02 |
| I6 | Unpublish a trip nobody booked. | It disappears from Home. | ADM-TRIP-05 |
| I7 | Unpublish a trip that already has a paid booking. | The booker still sees it in My Trips. New users do not see it on Home. | ADM-TRIP-06 |
| I8 | After Flow D payment success, open the booking in admin. | Package, room, adults, children, babies, main booker, and family member match the phone. Status is paid. | ADM-BOOK-01, ADM-BOOK-02, ADM-BOOK-04 |
| I9 | Add a flight, a hotel voucher, and itinerary steps. | Trip tabs Flights, Hotels, and Itinerary match. | ADM-OPS-01, ADM-OPS-02, ADM-OPS-03 |
| I10 | Upload a passport file on the booking. | Mobile Documents shows it and it opens. | ADM-OPS-04 |
| I11 | User uploads a document on the phone (Flow E step E9). | Admin document list shows the same file, type, and name. | ADM-OPS-05 |
| I12 | Edit packing list, emergency contact, FAQ, terms, and prayer times. | The matching phone screen matches after refresh. | ADM-CMS-01 to ADM-CMS-05, ADM-CMS-09 |
| I13 | Send a chat message into the trip group. | The phone thread and the chat-list preview show it. | ADM-CHAT-02 |
| I14 | Send a notification to that user. | The phone list shows title and body. Tap marks it read. | ADM-NOT-01 |

**Admin edge cases**

| ID | Priority | What you do | Must happen |
| --- | --- | --- | --- |
| ADM-USER-02 | High | Second user with the same email or phone. | Admin save is rejected. Mobile sign-up shows the same conflict. |
| ADM-USER-05 | Medium | Mark the user as guide. | Phone opens the guide area, not the traveller tabs. |
| ADM-USER-06 | High | Admin sets a temporary password. | Phone signs in with it. The old password fails. |
| ADM-TRIP-04 | High | Save a trip with no image. | Phone card does not crash. A placeholder is shown. |
| ADM-TRIP-07 | Medium | Save a translated title, if admin has languages. | The phone shows that language after the user switches language. |
| ADM-BOOK-03 | High | Phone payment is declined (Flow D edge MOB-PAY-02). | Admin does not show a paid booking. |
| ADM-BOOK-05 | Medium | Admin edits a hotel date. | Phone Hotels tab shows the new date after refresh. |
| ADM-BOOK-06 | High | Admin cancels the booking. | Phone My Trips no longer treats it as active. Payment history still opens. |
| ADM-OPS-06 | Medium | Admin deletes a document. | Phone Documents drops it after refresh. |
| ADM-OPS-07 | Medium | Admin adds or clears insurance. | Phone insurance screen matches. |
| ADM-CMS-06 | Medium | Edit terms, privacy, and a social link. | Phone pages show the new text. The social link opens the right site. |
| ADM-CMS-07 | Medium | Add a location and a team member with a photo. | Phone lists show them. A broken photo uses the placeholder. |
| ADM-CMS-08 | High | Delete every FAQ. | Phone FAQ shows the empty state, not an error screen. |
| ADM-CHAT-01 | High | Booking becomes active. | That user sees the trip group in Chat. |
| ADM-CHAT-03 | Medium | Remove the user from the group. | The group disappears from that user’s Chat tab. |
| ADM-NOT-02 | Medium | Send a push while the app is closed. | The device shows it. Tap opens the app. |
| ADM-NOT-03 | Medium | Send a push to a logged-out user. | It is not listed inside the app until they sign in. |

---

## Flow J — Shared checks on every build

Run these after Flows A to G. They are not a separate feature. They protect the flows above.

| ID | Priority | What you do | Must happen |
| --- | --- | --- | --- |
| MOB-GEN-01 | High | Airplane mode, then open Home, Trip, Chat, and Profile. | A clear error or empty state. No red error screen. |
| MOB-GEN-02 | High | Open any screen with network images on a slow network. | Shimmer until the image loads. Colors are the app shimmer colors. |
| MOB-GEN-03 | Medium | System back on Room, Person, Family, and Summary. Then system back on Home, Chat, and Profile. | Booking screens ask before discard. The other screens go back once. |
| MOB-GEN-05 | Medium | Repeat Flow C and Flow D on a small phone and a large phone. | No yellow-black overflow stripes. The pay button stays reachable. |
| MOB-GEN-06 | Low | Turn on dark mode. Repeat Home, Trip, Chat, and Profile. | Text stays readable. Tabs and cards use the dark colors. |

---

## Release comparison sheet

Tick a flow only when its happy path and its High edge cases passed on Android and iOS.

| Flow | What you compared | Android | iOS |
| --- | --- | --- | --- |
| A | Logged-out start, sign in, reopen, logout |  |  |
| B | Sign up and password reset |  |  |
| C | Home scroll, Current/Past, open trip |  |  |
| D | Full booking through successful payment |  |  |
| D edge | Declined card does not create a paid booking |  |  |
| E | My Trips tools, document upload, offline |  |  |
| F | Chat list, send text, empty state |  |  |
| G | Profile edit and Help pages |  |  |
| H | Expired access token refreshes and retries |  |  |
| I | One admin edit is visible on the phone |  |  |
| J | Airplane mode on the four tabs |  |  |
