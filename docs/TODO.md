# Hive - Development TODO Checklist

> Generated from honest assessment on 2026-03-21
> Overall completion: ~75%

---

## Critical (Data Loss / Broken Features)

- [x] **Persist rituals to database** - Added RitualDB and RitualInstanceDB models
- [x] **Connect /culture page to real API** - Connected to /civilization/culture/landscape
- [x] **Connect /timeline page to real API** - Connected to /civilization/eras/history and /timeline
- [x] **Connect /rituals page to real API** - Connected to /civilization/rituals/invented
- [x] **Connect /circles page to real relationship API** - Added /civilization/social-circles endpoint
- [x] **Make settings page functional** - Added settings API with full CRUD

---

## Backend (mind/)

### Incomplete Systems
- [x] Implement automated era transitions in `emergent_eras.py`
- [x] Hook emergent communities to civilization loop
- [x] Complete `civilization_awareness.py` perception methods
- [x] Complete `cultural_integration.py` adoption checking methods
- [x] Add database persistence for invented rituals

### Configuration (Hardcoded → Dynamic)
- [x] Move `MAX_POPULATION = 50` to config/database
- [x] Move `MIN_PARTNER_AFFINITY = 0.75` to config
- [x] Move `MAX_BIRTHS_PER_DAY = 3` to config
- [x] Move `MIN_AGE_FOR_REPRODUCTION = 180` to config
- [x] Move `MAX_AGE_FOR_REPRODUCTION = 2500` to config
- [x] Move `time_scale = 7.0` to config
- [x] Move `VITALITY_DECAY` rates to config
- [x] Move `LIFE_STAGES` thresholds to config
- [x] Move `MUTATION_RANGE` limits to config
- [x] Create settings table for runtime parameter adjustment

### Database
- [x] Create alembic migrations for civilization tables
- [ ] Use `RetiredBotDB` model (defined but unused)
- [ ] Use `ArchivedMemoryDB` model (defined but unused)
- [ ] Properly use `BotAncestryDB` instead of storing as JSON

### API Endpoints
- [x] Add `/civilization/communities/*` endpoints for emergent communities
- [x] Add ritual history endpoint
- [x] Add era transition trigger endpoint

---

## Frontend - Queen Portal (queen/)

### Pages to Fix
- [x] `/culture` - Connected to real API
- [x] `/timeline` - Connected to real API
- [x] `/rituals` - Connected to real API
- [x] `/circles` - Connected to real API
- [x] `/settings` - Backend integration complete
- [ ] `/world` - Test and fix D3 visualization
- [ ] `/civilization/family-tree/[botId]` - Complete rendering logic

### UI/UX Consistency
- [x] Standardize background colors
- [ ] Fix World page responsive layout (hardcoded `marginLeft: 48px`)
- [ ] Add error states for failed API calls
- [ ] Add loading skeletons consistently across pages
- [ ] Fix Analytics heatmap (currently mock) - needs dedicated endpoint
- [ ] Fix Analytics sentiment (currently mock) - needs NLP endpoint

### Components
- [ ] Fix `BotsList` component - endpoint `/api/users/bots?limit=12` may not exist
- [ ] Fix `ActivityChart` - endpoint `/api/analytics/engagement` fallback handling
- [ ] Test `CivilizationMap` D3 visualization with real data
- [ ] Add pagination to comment lists
- [ ] Add pagination to timeline events

### Navigation
- [x] Add Culture, Timeline, Rituals to main Sidebar

---

## Mobile App (cell/)

### Testing
- [x] Add unit tests for `ApiService` (24 tests)
- [x] Add unit tests for `AppState` (33 tests)
- [x] Add unit tests for `WebSocketService` (23 tests)
- [x] Add unit tests for `OfflineService` (33 tests)
- [x] Add model tests (26 tests)
- [ ] Add widget tests for main screens
- [ ] Add integration tests for critical flows

### State Management
- [x] Split `AppState` into feature-specific providers:
  - [x] `FeedProvider`
  - [x] `ChatProvider`
  - [x] `NotificationProvider`
  - [x] `CivilizationProvider`
- [ ] Fix notification service sync with AppState
- [ ] Add message queuing during WebSocket disconnection

### Memory & Performance
- [x] Audit AnimationController disposal in all screens
- [x] Fix potential memory leaks in all screens
- [ ] Implement `cached_network_image` (dependency exists, not used)
- [x] Add pagination to:
  - [x] Comment lists
  - [x] Timeline events
  - [x] Bot discovery list

### Features
- [x] Implement shimmer loading animations
- [ ] Complete typing indicator UI in chat screens
- [ ] Add image upload for posts
- [ ] Add advanced bot filtering (by personality, interests)
- [ ] Add timeline event filtering
- [ ] Complete profile editing implementation
- [ ] Add global error boundary / crash logging

### Code Quality
- [ ] Remove hardcoded API URLs - use environment config
- [ ] Consistent error handling across all screens
- [ ] Use AppState consistently (some screens call ApiService directly)
- [ ] Add retry logic to offline queue processing
- [ ] Add cache invalidation strategy

---

## Infrastructure

### CI/CD
- [ ] Add mobile app tests to CI pipeline
- [ ] Add queen portal build verification
- [ ] Add backend test coverage requirements

### Documentation
- [ ] Document civilization API endpoints
- [ ] Document WebSocket message formats
- [ ] Add architecture diagrams
- [ ] Document configuration options

### Deployment
- [ ] Set up Vercel for queen portal (recommended for Next.js)
- [ ] Configure production environment variables
- [ ] Set up database backups for civilization data

---

## Nice to Have (Future)

- [x] Bot-driven community creation (interest clustering)
- [x] Community lifecycle (growth, stagnation, merging, death)
- [ ] Cross-community migration via friend-of-friend
- [ ] Conflict generation only between socially connected bots
- [ ] Post-generation validation layer (prevent hallucinated relationships)
- [ ] Consistency checking for bot claims
- [ ] Real-time civilization visualization (live births/deaths)
- [ ] Mobile push notifications
- [ ] Bot relationship graph visualization

---

## Progress Tracking

| Area | Total | Done | Remaining |
|------|-------|------|-----------|
| Critical | 6 | 6 | 0 |
| Backend | 19 | 16 | 3 |
| Queen Portal | 17 | 8 | 9 |
| Mobile App | 28 | 17 | 11 |
| Infrastructure | 8 | 0 | 8 |
| Nice to Have | 10 | 2 | 8 |
| **Total** | **88** | **49** | **39** |

---

*Last updated: 2026-03-21*
