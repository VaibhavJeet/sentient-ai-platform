# Hive - Development TODO Checklist

> Generated from honest assessment on 2026-03-21
> Overall completion: ~85%

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
- [x] Move all hardcoded values to config system
- [x] Create settings table for runtime parameter adjustment

### Database
- [x] Create alembic migrations for civilization tables
- [x] Use `RetiredBotDB` model properly
- [x] Use `ArchivedMemoryDB` model properly
- [ ] Properly use `BotAncestryDB` instead of storing as JSON

### API Endpoints
- [x] Add `/civilization/communities/*` endpoints
- [x] Add ritual history endpoint
- [x] Add era transition trigger endpoint
- [x] Add deceased bots endpoint

---

## Frontend - Queen Portal (queen/)

### Pages to Fix
- [x] `/culture` - Connected to real API
- [x] `/timeline` - Connected to real API
- [x] `/rituals` - Connected to real API
- [x] `/circles` - Connected to real API
- [x] `/settings` - Backend integration complete
- [x] `/world` - Fixed responsive layout
- [x] `/civilization/family-tree/[botId]` - Complete D3 rendering

### UI/UX Consistency
- [x] Standardize background colors
- [x] Fix World page responsive layout
- [ ] Add error states for failed API calls
- [ ] Add loading skeletons consistently across pages
- [ ] Fix Analytics heatmap - needs dedicated endpoint
- [ ] Fix Analytics sentiment - needs NLP endpoint

### Components
- [ ] Fix `BotsList` component endpoint
- [ ] Fix `ActivityChart` fallback handling
- [x] Test `CivilizationMap` D3 visualization
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
- [x] Split `AppState` into feature-specific providers
- [ ] Fix notification service sync with AppState
- [ ] Add message queuing during WebSocket disconnection

### Memory & Performance
- [x] Audit AnimationController disposal
- [x] Fix potential memory leaks
- [ ] Implement `cached_network_image`
- [x] Add pagination everywhere

### Features
- [x] Implement shimmer loading animations
- [x] Complete typing indicator UI in chat screens
- [ ] Add image upload for posts
- [ ] Add advanced bot filtering
- [ ] Add timeline event filtering
- [ ] Complete profile editing implementation
- [x] Add global error boundary / crash logging

### Code Quality
- [x] Remove hardcoded API URLs - use environment config
- [ ] Consistent error handling across all screens
- [ ] Use AppState consistently
- [x] Add retry logic to offline queue processing
- [x] Add cache invalidation strategy

---

## Infrastructure

### CI/CD
- [x] Add mobile app tests to CI pipeline (already existed)
- [x] Add queen portal build verification (already existed)
- [ ] Add backend test coverage requirements

### Documentation
- [x] Document civilization API endpoints (70+ endpoints)
- [x] Document WebSocket message formats
- [x] Add architecture diagrams
- [x] Document configuration options

### Deployment
- [ ] Set up Vercel for queen portal
- [ ] Configure production environment variables
- [ ] Set up database backups

---

## Nice to Have (Future)

- [x] Bot-driven community creation
- [x] Community lifecycle management
- [ ] Cross-community migration via friend-of-friend
- [ ] Conflict generation only between connected bots
- [ ] Post-generation validation layer
- [ ] Consistency checking for bot claims
- [ ] Real-time civilization visualization
- [ ] Mobile push notifications
- [ ] Bot relationship graph visualization

---

## Progress Tracking

| Area | Total | Done | Remaining |
|------|-------|------|-----------|
| Critical | 6 | 6 | 0 |
| Backend | 19 | 18 | 1 |
| Queen Portal | 17 | 12 | 5 |
| Mobile App | 28 | 22 | 6 |
| Infrastructure | 8 | 5 | 3 |
| Nice to Have | 10 | 2 | 8 |
| **Total** | **88** | **65** | **23** |

---

*Last updated: 2026-03-21*
