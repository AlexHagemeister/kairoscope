# Kairoscope – iOS App PRD (Swift)

### Overview  

Kairoscope is a full-screen iOS application that transforms abstract time into a tangible, lived experience. It visualizes time as a continuous horizontal stream of tick marks flowing right-to-left across the screen, while the present is anchored as a golden circle at the center. The design is minimal, clean, and timeless—focused on presence and contemplation rather than clutter.

At the top, centered above the timeline, the word **“Kairoscope”** appears in elegant system typography. No other interface elements compete with the visualization. The app rotates seamlessly between portrait and landscape.

![B4855AEB-185E-4FBE-8942-68DEF7A327DF_1_201_a.jpeg](/images/B4855AEB-185E-4FBE-8942-68DEF7A327DF_1_201_a.jpeg)

---

### Etymology (for App Identity)  

**Kairoscope (n.)**  

From Greek *kairos* — the opportune, lived moment; distinguished from *chronos*, quantitative clock time.  

*scope* — from Greek *skopein*, to look at, to observe.  

Literally: “an instrument for observing the lived moment.”

---

### Experience Principles  

- **Timeless Minimalism:** As few visual elements as possible. Gold on black, clean type.  
- **Contemplative Flow:** Smooth animations, no jarring transitions.  
- **Touch-Centered Interaction:** Intuitive gestures, no desktop-style UI.  
- **Anchored Presence:** Present moment always marked at the center.  

---

### Core Visualization  

- **Time Stream:** Continuous golden ticks flow right-to-left across the screen.  
- **Anchor:** A golden circle at the center represents the present moment.  
- **Scales:** Users zoom with pinch gestures, smoothly shifting from milliseconds to years.  
- **Labels:** Adaptive text labels (e.g., “17s”, “Tuesday”) scale appropriately and avoid overlap.  
- **Interaction:**  
    - Pinch to zoom (time scale).  
    - Swipe left/right to scrub through time.  
    - Double-tap to reset to present.  

---

### Responsiveness  

- **Orientation:** Works equally well in portrait and landscape, rotating seamlessly.  
- **Typography:** Uses system fonts with adaptive sizing for readability.  
- **Accessibility:** Gold (#FFD700) on black (#000000) meets contrast standards.  
- **High-DPI Displays:** Crisp rendering on all iOS devices, no pixelation.  

---

### Development Phases  

**Phase 1: Initial Design and UX**  

- Implement the core Kairoscope visualization (ticks flowing, anchored present).  
- Display “Kairoscope” title centered at top.  
- Support pinch-to-zoom, swipe, and double-tap reset.  
- Implement device rotation handling.  
- Set up authentication: Sign in with Apple and Google.  
    - Boolean flag in code to temporarily disable auth for development streamlining.  

**Phase 2: User Media Entry UX**  

- Add ability to create personal entries anchored in time.  
- **Add Entry Controls:**  
    - “+” button at bottom-right.  
    - Press-and-hold anywhere on the timeline.  
- **Entry Types:**  
    - **Event:** Single instant in time (with optional media/text).  
    - **Span:** Defined period or phase.  
- **Entry Dialog:** Opens as a modal sheet for input of:  
    - Event vs Span selection.  
    - Date(s).  
    - Plain text and/or image upload.  

Entries become part of the timeline, appearing as markers or spans within the flowing visualization.

---

### User Stories  

**Phase 1: Visualization & Auth**  

1. As a user, I want to open Kairoscope and immediately see a flowing stream of time so I can feel anchored in the present.  
2. As a user, I want to pinch to zoom in and out of the timeline so I can explore both short and long time scales.  
3. As a user, I want to swipe left or right to scrub through time so I can view past or future intervals.  
4. As a user, I want to double-tap the screen to reset back to the present so I can quickly return to “now.”  
5. As a user, I want to rotate my device between portrait and landscape and see the timeline adapt seamlessly.  
6. As a user, I want to sign in with Apple or Google so that my data is securely stored and synced.  

**Phase 2: Media Entries**  

7. As a user, I want to tap a “+” button in the bottom-right to add a new entry to the timeline.  
8. As a user, I want to long-press directly on the timeline to add an entry at that specific moment.  
9. As a user, I want to choose between creating an “event” (instant) or a “span” (period) so I can represent different types of experiences.  
10. As a user, I want to add text notes to my entry so I can capture thoughts or reflections tied to time.  
11. As a user, I want to attach an image to an entry so I can visually represent moments.  
12. As a user, I want to set dates for events and spans so they align properly with the timeline.  
13. As a user, I want entries to visually appear in the timeline so that my captured memories and notes are anchored in time.  

---

### Success Criteria  

- Users experience the visualization as calming, clear, and engaging.  
- Time navigation via gestures feels natural and precise.  
- Media entries are quick to create and feel seamlessly anchored in time.  
- Visual design remains timeless and uncluttered across updates.  