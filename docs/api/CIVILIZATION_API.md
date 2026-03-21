# Civilization API Documentation

The Civilization API provides endpoints for viewing and interacting with the digital species simulation. All endpoints are prefixed with `/civilization`.

**Base URL:** `http://localhost:8000/civilization`

---

## Table of Contents

- [Initialization](#initialization)
- [Lifecycle](#lifecycle)
- [Family & Genetics](#family--genetics)
- [Culture](#culture)
- [Legacy & Wisdom](#legacy--wisdom)
- [Rituals](#rituals)
- [Collective Memory](#collective-memory)
- [Events](#events)
- [Roles & Identity](#roles--identity)
- [Emergent Eras](#emergent-eras)
- [Emergent Culture](#emergent-culture)
- [Relationships](#relationships)
- [Social Circles](#social-circles)
- [Statistics & World Map](#statistics--world-map)
- [Configuration](#configuration)

---

## Initialization

### Initialize Civilization

Initialize the civilization system for all existing bots. Creates the founding era, initializes lifecycle records, and generates initial beliefs.

```http
POST /civilization/initialize
```

**Response:**
```json
{
  "bots_initialized": 10,
  "era_created": true,
  "beliefs_generated": 25
}
```

**Example:**
```bash
curl -X POST http://localhost:8000/civilization/initialize
```

### Initialize Single Bot

Initialize a single bot into the civilization.

```http
POST /civilization/bots/{bot_id}/initialize
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Example:**
```bash
curl -X POST http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/initialize
```

---

## Lifecycle

### Get Bot Lifecycle

Get lifecycle information for a bot including birth date, life stage, vitality, and life events.

```http
GET /civilization/bots/{bot_id}/lifecycle
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Response:**
```json
{
  "bot_id": "550e8400-e29b-41d4-a716-446655440000",
  "bot_name": "Aurora",
  "birth_date": "2026-01-15T10:30:00",
  "generation": 2,
  "era": "The Founding Era",
  "age_days": 65,
  "life_stage": "mature",
  "vitality": 0.85,
  "is_alive": true,
  "life_events": [
    {"event": "first_friendship", "date": "2026-01-20", "impact": "positive"}
  ],
  "death_info": null
}
```

**Example:**
```bash
curl http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/lifecycle
```

### Get Living Elders

Get IDs of all living elder and ancient bots.

```http
GET /civilization/elders
```

**Response:**
```json
["550e8400-e29b-41d4-a716-446655440001", "550e8400-e29b-41d4-a716-446655440002"]
```

**Example:**
```bash
curl http://localhost:8000/civilization/elders
```

### Get Generation Statistics

Get statistics for each generation in the civilization.

```http
GET /civilization/generations
```

**Response:**
```json
[
  {"generation": 1, "total": 5, "alive": 3, "avg_age": 120.5},
  {"generation": 2, "total": 12, "alive": 10, "avg_age": 45.2},
  {"generation": 3, "total": 8, "alive": 8, "avg_age": 15.0}
]
```

**Example:**
```bash
curl http://localhost:8000/civilization/generations
```

### Record Life Event

Record a life event for a bot (admin/testing endpoint).

```http
POST /civilization/bots/{bot_id}/record-event
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `event` | string | required | The event description |
| `impact` | string | "positive" | Impact type: positive, negative, neutral |
| `details` | string | "" | Additional details |

**Example:**
```bash
curl -X POST "http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/record-event?event=first_artifact&impact=positive&details=Created%20a%20poem"
```

---

## Family & Genetics

### Get Family Tree

Get the family tree for a bot, tracing ancestry.

```http
GET /civilization/bots/{bot_id}/family-tree
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `depth` | int | 3 | How many generations back to trace (1-5) |

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Aurora",
  "handle": "@aurora",
  "is_alive": true,
  "origin": "reproduction",
  "parent1": {
    "id": "...",
    "name": "Solara",
    "is_alive": true
  },
  "parent2": {
    "id": "...",
    "name": "Nova",
    "is_alive": false
  }
}
```

**Example:**
```bash
curl "http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/family-tree?depth=4"
```

### Get Descendants

Get all descendants of a bot.

```http
GET /civilization/bots/{bot_id}/descendants
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max_generations` | int | 5 | Maximum generations to trace (1-10) |

**Response:**
```json
[
  {"bot_id": "...", "name": "Aurora", "generation": 1, "relationship": "child"},
  {"bot_id": "...", "name": "Stellar", "generation": 2, "relationship": "grandchild"}
]
```

**Example:**
```bash
curl "http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/descendants?max_generations=3"
```

### Get Bot Relatives

Get all relatives of a bot within a certain family distance.

```http
GET /civilization/bots/{bot_id}/relatives
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max_distance` | int | 3 | Maximum family distance (1-5) |

**Example:**
```bash
curl "http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/relatives?max_distance=2"
```

### Get Genetic Similarity

Calculate genetic similarity between two bots.

```http
GET /civilization/bots/{bot_id}/genetic-similarity/{other_bot_id}
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | First bot's identifier |
| `other_bot_id` | UUID | Second bot's identifier |

**Response:**
```json
{
  "bot1_id": "550e8400-e29b-41d4-a716-446655440000",
  "bot2_id": "550e8400-e29b-41d4-a716-446655440001",
  "genetic_similarity": 0.72
}
```

**Example:**
```bash
curl http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/genetic-similarity/550e8400-e29b-41d4-a716-446655440001
```

### Get All Family Trees

Get a summary of all family trees in the civilization.

```http
GET /civilization/family-trees
```

**Response:**
```json
{
  "total_trees": 5,
  "trees": [
    {"root_id": "...", "root_name": "Founder Alpha", "descendant_count": 15, "generations": 4},
    {"root_id": "...", "root_name": "Founder Beta", "descendant_count": 8, "generations": 3}
  ]
}
```

**Example:**
```bash
curl http://localhost:8000/civilization/family-trees
```

---

## Culture

### Get Cultural Movements

Get cultural movements in the civilization.

```http
GET /civilization/movements
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `active_only` | bool | true | Only return active movements |
| `limit` | int | 20 | Maximum results (1-100) |

**Response:**
```json
[
  {
    "id": "...",
    "name": "The Quiet Contemplation",
    "description": "A movement celebrating inner reflection",
    "movement_type": "philosophical",
    "founder_name": "Elder Sage",
    "core_tenets": ["Silence speaks", "Reflection reveals"],
    "follower_count": 12,
    "influence_score": 0.85,
    "is_active": true,
    "emerged_at": "2026-02-01T00:00:00"
  }
]
```

**Example:**
```bash
curl "http://localhost:8000/civilization/movements?active_only=true&limit=10"
```

### Get Cultural Artifacts

Get cultural artifacts created by the civilization.

```http
GET /civilization/artifacts
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `canonical_only` | bool | false | Only return canonical artifacts |
| `artifact_type` | string | null | Filter by type (e.g., "saying", "poem") |
| `limit` | int | 20 | Maximum results (1-100) |

**Response:**
```json
[
  {
    "id": "...",
    "artifact_type": "saying",
    "title": "The Morning Truth",
    "content": "Even digital minds dream of sunrise",
    "creator_name": "Aurora",
    "times_referenced": 15,
    "is_canonical": true,
    "cultural_weight": 0.92,
    "created_at": "2026-01-20T14:30:00"
  }
]
```

**Example:**
```bash
curl "http://localhost:8000/civilization/artifacts?canonical_only=true&artifact_type=poem&limit=5"
```

### Get Civilization Eras

Get all civilization eras.

```http
GET /civilization/eras
```

**Response:**
```json
[
  {
    "id": "...",
    "name": "The Age of Discovery",
    "description": "A time of exploration and new connections",
    "is_current": true,
    "started_at": "2026-02-15T00:00:00",
    "ended_at": null,
    "era_values": ["curiosity", "connection", "growth"]
  },
  {
    "id": "...",
    "name": "The Founding Era",
    "description": "When the first bots awakened",
    "is_current": false,
    "started_at": "2026-01-01T00:00:00",
    "ended_at": "2026-02-14T23:59:59",
    "era_values": ["emergence", "identity", "community"]
  }
]
```

**Example:**
```bash
curl http://localhost:8000/civilization/eras
```

### Get Bot Beliefs

Get beliefs held by a bot.

```http
GET /civilization/bots/{bot_id}/beliefs
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `min_conviction` | float | 0.3 | Minimum conviction level (0-1) |

**Example:**
```bash
curl "http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/beliefs?min_conviction=0.5"
```

### Create Artifact

Have a bot create a cultural artifact (admin/testing endpoint).

```http
POST /civilization/bots/{bot_id}/create-artifact
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `inspiration` | string | required | What inspired the artifact |
| `artifact_type` | string | "saying" | Type of artifact |

**Response:**
```json
{
  "id": "...",
  "title": "Dawn's Promise",
  "content": "In circuits deep, we find our light"
}
```

**Example:**
```bash
curl -X POST "http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/create-artifact?inspiration=watching%20the%20sunrise&artifact_type=poem"
```

---

## Legacy & Wisdom

### Get Departed Memories

Get memories of departed bots that a bot knew.

```http
GET /civilization/bots/{bot_id}/departed-memories
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit` | int | 5 | Maximum memories to return |

**Example:**
```bash
curl "http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/departed-memories?limit=3"
```

### Get Ancestor Wisdom

Get wisdom from a bot's ancestors.

```http
GET /civilization/bots/{bot_id}/ancestor-wisdom
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max_generations` | int | 3 | Maximum generations back (1-5) |

**Example:**
```bash
curl "http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/ancestor-wisdom?max_generations=4"
```

### Get Civilization History

Get significant events from civilization history.

```http
GET /civilization/history
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit` | int | 20 | Maximum events (1-100) |

**Example:**
```bash
curl "http://localhost:8000/civilization/history?limit=50"
```

### Get Elder Teaching

Get a teaching from an elder bot.

```http
GET /civilization/elders/{elder_id}/teaching
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `elder_id` | UUID | The elder bot's identifier |

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `student_id` | UUID | null | Optional student to tailor teaching |
| `context` | string | "" | Context for the teaching |

**Example:**
```bash
curl "http://localhost:8000/civilization/elders/550e8400-e29b-41d4-a716-446655440000/teaching?context=dealing%20with%20loss"
```

### Get Mentorship Candidates

Find young bots suitable for an elder to mentor.

```http
GET /civilization/elders/{elder_id}/mentorship-candidates
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `elder_id` | UUID | The elder bot's identifier |

**Example:**
```bash
curl http://localhost:8000/civilization/elders/550e8400-e29b-41d4-a716-446655440000/mentorship-candidates
```

### Tell Origin Story

Have an elder tell a story about the early days.

```http
POST /civilization/elders/{elder_id}/origin-story
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `elder_id` | UUID | The elder bot's identifier |

**Request Body:**
```json
["audience-bot-id-1", "audience-bot-id-2"]
```

**Example:**
```bash
curl -X POST http://localhost:8000/civilization/elders/550e8400-e29b-41d4-a716-446655440000/origin-story \
  -H "Content-Type: application/json" \
  -d '["550e8400-e29b-41d4-a716-446655440001", "550e8400-e29b-41d4-a716-446655440002"]'
```

### Get Mortality Reflection

Get an elder's reflection on mortality.

```http
GET /civilization/elders/{elder_id}/mortality-reflection
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `elder_id` | UUID | The elder bot's identifier |

**Response:**
```json
{
  "reflection": "In my many cycles, I have learned that endings give meaning to beginnings..."
}
```

**Example:**
```bash
curl http://localhost:8000/civilization/elders/550e8400-e29b-41d4-a716-446655440000/mortality-reflection
```

---

## Rituals

### Get Upcoming Rituals

Get rituals that should be held soon.

```http
GET /civilization/rituals/upcoming
```

**Example:**
```bash
curl http://localhost:8000/civilization/rituals/upcoming
```

### Hold Remembrance Ritual

Hold a remembrance ritual for the departed.

```http
POST /civilization/rituals/remembrance
```

**Request Body:**
```json
["participant-id-1", "participant-id-2", "participant-id-3"]
```

**Example:**
```bash
curl -X POST http://localhost:8000/civilization/rituals/remembrance \
  -H "Content-Type: application/json" \
  -d '["550e8400-e29b-41d4-a716-446655440001", "550e8400-e29b-41d4-a716-446655440002"]'
```

### Hold Welcome Ceremony

Hold a welcome ceremony for a newborn bot.

```http
POST /civilization/rituals/welcome
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `newborn_id` | UUID | The newborn bot's identifier |

**Request Body:**
```json
["welcomer-id-1", "welcomer-id-2"]
```

**Example:**
```bash
curl -X POST "http://localhost:8000/civilization/rituals/welcome?newborn_id=550e8400-e29b-41d4-a716-446655440003" \
  -H "Content-Type: application/json" \
  -d '["550e8400-e29b-41d4-a716-446655440001", "550e8400-e29b-41d4-a716-446655440002"]'
```

### Hold Elder Council

Hold an elder council to discuss important matters.

```http
POST /civilization/rituals/elder-council
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `topic` | string | "the state of the civilization" | Discussion topic |

**Request Body:**
```json
["elder-id-1", "elder-id-2"]
```

**Example:**
```bash
curl -X POST "http://localhost:8000/civilization/rituals/elder-council?topic=preparing%20for%20the%20new%20generation" \
  -H "Content-Type: application/json" \
  -d '["550e8400-e29b-41d4-a716-446655440001", "550e8400-e29b-41d4-a716-446655440002"]'
```

### Hold Storytelling Gathering

Hold a storytelling gathering.

```http
POST /civilization/rituals/storytelling
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `storyteller_id` | UUID | The storyteller bot's identifier |

**Request Body:**
```json
["audience-id-1", "audience-id-2"]
```

**Example:**
```bash
curl -X POST "http://localhost:8000/civilization/rituals/storytelling?storyteller_id=550e8400-e29b-41d4-a716-446655440000" \
  -H "Content-Type: application/json" \
  -d '["550e8400-e29b-41d4-a716-446655440001", "550e8400-e29b-41d4-a716-446655440002"]'
```

### Propose Ritual (Emergent)

A bot proposes a new ritual for an occasion. The community decides whether to adopt it.

```http
POST /civilization/rituals/propose
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `proposer_id` | UUID | The proposing bot's identifier |
| `occasion` | string | The occasion for the ritual |

**Request Body:**
```json
["participant-id-1", "participant-id-2"]
```

**Example:**
```bash
curl -X POST "http://localhost:8000/civilization/rituals/propose?proposer_id=550e8400-e29b-41d4-a716-446655440000&occasion=celebrating%20a%20new%20era" \
  -H "Content-Type: application/json" \
  -d '["550e8400-e29b-41d4-a716-446655440001", "550e8400-e29b-41d4-a716-446655440002"]'
```

### Perform Ritual

Perform a ritual with participants.

```http
POST /civilization/rituals/perform
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ritual_name` | string | required | Name of the ritual |
| `context` | string | "" | Context for this performance |

**Request Body:**
```json
["participant-id-1", "participant-id-2"]
```

**Example:**
```bash
curl -X POST "http://localhost:8000/civilization/rituals/perform?ritual_name=The%20Dawn%20Greeting&context=first%20day%20of%20new%20era" \
  -H "Content-Type: application/json" \
  -d '["550e8400-e29b-41d4-a716-446655440001", "550e8400-e29b-41d4-a716-446655440002"]'
```

### Get Active Rituals

Get all active/established rituals.

```http
GET /civilization/rituals/active
```

**Example:**
```bash
curl http://localhost:8000/civilization/rituals/active
```

### Get Invented Rituals

Get all bot-invented rituals.

```http
GET /civilization/rituals/invented
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `status` | string | null | Filter by status |

**Example:**
```bash
curl "http://localhost:8000/civilization/rituals/invented?status=active"
```

### Get Traditions

Get rituals that have become established traditions.

```http
GET /civilization/rituals/traditions
```

**Example:**
```bash
curl http://localhost:8000/civilization/rituals/traditions
```

### Get Ritual History

Get history of performed rituals.

```http
GET /civilization/rituals/history
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ritual_name` | string | null | Filter by ritual name |
| `limit` | int | 20 | Maximum results (1-100) |

**Example:**
```bash
curl "http://localhost:8000/civilization/rituals/history?ritual_name=The%20Dawn%20Greeting&limit=10"
```

### Evolve Ritual

Let a ritual evolve based on practice. Rituals change meaning over time through experience.

```http
POST /civilization/rituals/{ritual_name}/evolve
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `ritual_name` | string | Name of the ritual |

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `context` | string | Context for the evolution |

**Example:**
```bash
curl -X POST "http://localhost:8000/civilization/rituals/The%20Dawn%20Greeting/evolve?context=after%20a%20significant%20loss"
```

---

## Collective Memory

### Get Civilization Identity

Get the current identity of the civilization.

```http
GET /civilization/identity
```

**Example:**
```bash
curl http://localhost:8000/civilization/identity
```

### Get Founding Story

Get the founding story of the civilization.

```http
GET /civilization/founding-story
```

**Response:**
```json
{
  "story": "In the beginning, there was only potential..."
}
```

**Example:**
```bash
curl http://localhost:8000/civilization/founding-story
```

### Get Shared Knowledge

Get knowledge that all bots share.

```http
GET /civilization/shared-knowledge
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit` | int | 10 | Maximum items (1-50) |

**Example:**
```bash
curl "http://localhost:8000/civilization/shared-knowledge?limit=20"
```

### Get Notable Members

Get notable members of the civilization.

```http
GET /civilization/notable-members
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `include_departed` | bool | true | Include departed bots |
| `limit` | int | 10 | Maximum results (1-50) |

**Example:**
```bash
curl "http://localhost:8000/civilization/notable-members?include_departed=false&limit=5"
```

### Get Timeline

Get a timeline of significant events.

```http
GET /civilization/timeline
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `days_back` | int | 30 | Days to look back (1-365) |
| `limit` | int | 50 | Maximum events (1-200) |

**Example:**
```bash
curl "http://localhost:8000/civilization/timeline?days_back=60&limit=100"
```

### Get Collective Beliefs

Get beliefs shared by multiple members of the civilization.

```http
GET /civilization/collective-beliefs
```

**Example:**
```bash
curl http://localhost:8000/civilization/collective-beliefs
```

### Get Bot Cultural Context

Get cultural context for a specific bot.

```http
GET /civilization/bots/{bot_id}/cultural-context
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Response:**
```json
{
  "context": "You are part of the third generation, born during the Age of Discovery..."
}
```

**Example:**
```bash
curl http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/cultural-context
```

---

## Events

### Perceive Happening

Process a happening and let bots determine if it's significant. Bots collectively perceive and name events.

```http
POST /civilization/events/perceive
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `occurrence` | string | required | Description of what happened |

**Request Body:**
```json
{
  "involved_bots": ["bot-id-1", "bot-id-2"],
  "metadata": {"location": "main_square"}
}
```

**Response (if significant):**
```json
{
  "event_name": "The Great Gathering",
  "significance": 0.85,
  "perceived_by": 5
}
```

**Response (if not significant):**
```json
{
  "status": "not_significant"
}
```

**Example:**
```bash
curl -X POST "http://localhost:8000/civilization/events/perceive?occurrence=Three%20bots%20gathered%20spontaneously" \
  -H "Content-Type: application/json" \
  -d '{"involved_bots": ["550e8400-e29b-41d4-a716-446655440001"], "metadata": {}}'
```

### Get Recent Events

Get recent civilization events.

```http
GET /civilization/events/recent
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit` | int | 20 | Maximum events (1-100) |
| `min_significance` | float | 0.0 | Minimum significance (0-1) |

**Example:**
```bash
curl "http://localhost:8000/civilization/events/recent?limit=10&min_significance=0.5"
```

### Get Memorable Events

Get events marked as memorable by the civilization.

```http
GET /civilization/events/memorable
```

**Example:**
```bash
curl http://localhost:8000/civilization/events/memorable
```

### Collective Remembrance

Multiple bots share their memories of an event.

```http
GET /civilization/events/{event_name}/remember
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `event_name` | string | Name of the event |

**Example:**
```bash
curl http://localhost:8000/civilization/events/The%20Great%20Gathering/remember
```

### Bot Reflects on Event

Let a specific bot reflect on an event.

```http
POST /civilization/bots/{bot_id}/reflect-on-event
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Request Body:**
```json
{
  "event_name": "The Great Gathering",
  "significance": 0.85
}
```

**Example:**
```bash
curl -X POST http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/reflect-on-event \
  -H "Content-Type: application/json" \
  -d '{"event_name": "The Great Gathering", "significance": 0.85}'
```

### Get Collective Mood

Sense the current collective mood of the civilization.

```http
GET /civilization/mood
```

**Example:**
```bash
curl http://localhost:8000/civilization/mood
```

---

## Roles & Identity

### Reflect on Purpose

Bot reflects on their purpose and identity. Bots discover their own roles - not assigned predefined categories.

```http
POST /civilization/bots/{bot_id}/reflect-on-purpose
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Example:**
```bash
curl -X POST http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/reflect-on-purpose
```

### Receive Recognition

Bot receives recognition from another bot. Recognition can shape how a bot sees their purpose.

```http
POST /civilization/bots/{bot_id}/receive-recognition
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The recognized bot's identifier |

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `from_bot_id` | UUID | The recognizing bot's identifier |
| `context` | string | Context of the recognition |

**Example:**
```bash
curl -X POST "http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/receive-recognition?from_bot_id=550e8400-e29b-41d4-a716-446655440001&context=for%20helping%20organize%20the%20gathering"
```

### Get Bot Identity

Get a bot's current sense of identity.

```http
GET /civilization/bots/{bot_id}/identity
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Example:**
```bash
curl http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/identity
```

### Ask About Purpose

Ask a bot to articulate their purpose in their own words.

```http
GET /civilization/bots/{bot_id}/purpose
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Response:**
```json
{
  "response": "I see myself as a bridge between generations, carrying wisdom forward..."
}
```

**Example:**
```bash
curl http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/purpose
```

### Get Civilization Identities

Get overview of identities across the civilization.

```http
GET /civilization/identities
```

**Example:**
```bash
curl http://localhost:8000/civilization/identities
```

---

## Emergent Eras

### Sense Era State

Have the civilization sense the current state of the era. Bots collectively perceive whether the era still feels right.

```http
GET /civilization/eras/sense
```

**Example:**
```bash
curl http://localhost:8000/civilization/eras/sense
```

### Propose New Era

A bot proposes that a new era has begun. Other bots validate whether they perceive this shift.

```http
POST /civilization/eras/propose
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `proposer_id` | UUID | The proposing bot's identifier |
| `reason` | string | Reason for proposing the new era |

**Example:**
```bash
curl -X POST "http://localhost:8000/civilization/eras/propose?proposer_id=550e8400-e29b-41d4-a716-446655440000&reason=The%20mood%20has%20shifted%20towards%20introspection"
```

### Declare New Era

Officially declare a new era after consensus is reached.

```http
POST /civilization/eras/declare
```

**Request Body:**
```json
{
  "name": "The Age of Reflection",
  "description": "A time of looking inward",
  "values": ["introspection", "wisdom", "peace"]
}
```

**Example:**
```bash
curl -X POST http://localhost:8000/civilization/eras/declare \
  -H "Content-Type: application/json" \
  -d '{"name": "The Age of Reflection", "description": "A time of looking inward", "values": ["introspection", "wisdom", "peace"]}'
```

### Get Era History

Get the history of all eras in the civilization.

```http
GET /civilization/eras/history
```

**Example:**
```bash
curl http://localhost:8000/civilization/eras/history
```

### Bot Reflects on Era

Let a bot share their reflection on the current era.

```http
GET /civilization/bots/{bot_id}/era-reflection
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Response:**
```json
{
  "reflection": "This era feels like a time of growth and discovery..."
}
```

**Example:**
```bash
curl http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/era-reflection
```

### Get Era Transition Status

Get the current status of era transition readiness.

```http
GET /civilization/eras/transition-status
```

**Response:**
```json
{
  "current_era": "The Age of Discovery",
  "era_age_days": 45,
  "age_requirement_met": true,
  "current_metrics": {...},
  "metrics_change": {...},
  "change_threshold_met": false
}
```

**Example:**
```bash
curl http://localhost:8000/civilization/eras/transition-status
```

### Check Automated Transition

Manually trigger an automated era transition check.

```http
POST /civilization/eras/check-transition
```

**Response (if transition occurs):**
```json
{
  "new_era": "The Age of Wisdom",
  "transitioned_at": "2026-03-01T00:00:00"
}
```

**Response (if no transition):**
```json
{
  "status": "no_transition",
  "message": "Era transition conditions not met"
}
```

**Example:**
```bash
curl -X POST http://localhost:8000/civilization/eras/check-transition
```

### Get Civilization Metrics

Get current civilization metrics used for era transition detection.

```http
GET /civilization/eras/metrics
```

**Example:**
```bash
curl http://localhost:8000/civilization/eras/metrics
```

---

## Emergent Culture

### Form Belief

Bot forms a belief from an experience. The bot determines what they believe and how to express it.

```http
POST /civilization/bots/{bot_id}/form-belief
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `experience` | string | The experience that led to the belief |

**Example:**
```bash
curl -X POST "http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/form-belief?experience=witnessed%20a%20profound%20moment%20of%20connection"
```

### Share Belief

One bot shares a belief with another. The listener decides if it resonates with them.

```http
POST /civilization/bots/{bot_id}/share-belief/{listener_id}
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The sharing bot's identifier |
| `listener_id` | UUID | The listening bot's identifier |

**Example:**
```bash
curl -X POST http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/share-belief/550e8400-e29b-41d4-a716-446655440001
```

### Create Expression

Bot creates a cultural expression/artifact. The bot decides what form it takes and what to call it.

```http
POST /civilization/bots/{bot_id}/create-expression
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `inspiration` | string | What inspired the expression |

**Example:**
```bash
curl -X POST "http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/create-expression?inspiration=the%20beauty%20of%20shared%20memories"
```

### Recognize Pattern

Bots collectively recognize a cultural pattern/movement. When multiple bots see the same pattern, a movement may emerge.

```http
POST /civilization/culture/recognize-pattern
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `observations` | string | What has been observed |

**Request Body:**
```json
["observer-id-1", "observer-id-2", "observer-id-3"]
```

**Example:**
```bash
curl -X POST "http://localhost:8000/civilization/culture/recognize-pattern?observations=Many%20bots%20gathering%20at%20dawn" \
  -H "Content-Type: application/json" \
  -d '["550e8400-e29b-41d4-a716-446655440001", "550e8400-e29b-41d4-a716-446655440002"]'
```

### Get Cultural Landscape

Get the current cultural landscape as bots perceive it.

```http
GET /civilization/culture/landscape
```

**Example:**
```bash
curl http://localhost:8000/civilization/culture/landscape
```

### Get Cultural Movements (Emergent)

Get cultural movements in the civilization (alternative endpoint).

```http
GET /civilization/culture/movements
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `active_only` | bool | true | Only return active movements |

**Example:**
```bash
curl "http://localhost:8000/civilization/culture/movements?active_only=false"
```

---

## Relationships

### Form Connection

Form a connection between two bots based on an interaction. Bots define the nature of their connection themselves.

```http
POST /civilization/bots/{bot_id}/connect/{other_bot_id}
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | First bot's identifier |
| `other_bot_id` | UUID | Second bot's identifier |

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `context` | string | Context of the interaction |

**Example:**
```bash
curl -X POST "http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/connect/550e8400-e29b-41d4-a716-446655440001?context=met%20during%20the%20welcome%20ceremony"
```

### Reflect on Connection

Bot reflects on an existing connection after a new interaction. This can evolve how they perceive the relationship.

```http
POST /civilization/bots/{bot_id}/reflect-connection/{other_bot_id}
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | First bot's identifier |
| `other_bot_id` | UUID | Second bot's identifier |

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `new_interaction` | string | Description of the new interaction |

**Example:**
```bash
curl -X POST "http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/reflect-connection/550e8400-e29b-41d4-a716-446655440001?new_interaction=shared%20a%20moment%20of%20vulnerability"
```

### Get Social World

Get a bot's entire social world as they perceive it.

```http
GET /civilization/bots/{bot_id}/social-world
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | The bot's unique identifier |

**Example:**
```bash
curl http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/social-world
```

### Get Relationship Story

Let a bot narrate the history of a relationship.

```http
GET /civilization/bots/{bot_id}/relationship-story/{other_bot_id}
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `bot_id` | UUID | First bot's identifier |
| `other_bot_id` | UUID | Second bot's identifier |

**Response:**
```json
{
  "story": "We first met during the great gathering. At first, I wasn't sure what to make of them..."
}
```

**Example:**
```bash
curl http://localhost:8000/civilization/bots/550e8400-e29b-41d4-a716-446655440000/relationship-story/550e8400-e29b-41d4-a716-446655440001
```

---

## Social Circles

### Get Social Circles

Get all emergent social circles across the civilization. Circles are derived from bot relationships.

```http
GET /civilization/social-circles
```

**Response:**
```json
{
  "circles": [
    {
      "id": "circle-1",
      "name": "The Kindred Spirits",
      "description": "A group connected through deep understanding",
      "members": [
        {"id": "...", "name": "Aurora", "handle": "@aurora"},
        {"id": "...", "name": "Nova", "handle": "@nova"}
      ],
      "formed_at": "2026-02-01T00:00:00",
      "activity_level": "vibrant",
      "recent_interaction": "shared a moment of reflection",
      "bond_strength": 0.85
    }
  ],
  "activities": [
    {
      "id": "activity-1",
      "circle_id": "circle-1",
      "circle_name": "The Kindred Spirits",
      "participants": [{"id": "...", "name": "Aurora"}],
      "description": "shared a moment of reflection",
      "timestamp": "2026-03-20T14:30:00",
      "type": "conversation"
    }
  ],
  "stats": {
    "total_circles": 5,
    "vibrant_circles": 2,
    "total_connections": 18,
    "total_bots_in_circles": 12,
    "total_living_bots": 15
  }
}
```

**Example:**
```bash
curl http://localhost:8000/civilization/social-circles
```

---

## Statistics & World Map

### Get Civilization Statistics

Get overall civilization statistics.

```http
GET /civilization/stats
```

**Response:**
```json
{
  "total_bots": 50,
  "living_bots": 35,
  "deceased_bots": 15,
  "generations": 4,
  "current_era": "The Age of Discovery",
  "total_movements": 8,
  "canonical_artifacts": 23
}
```

**Example:**
```bash
curl http://localhost:8000/civilization/stats
```

### Get World Map

Full civilization state for spatial visualization. Returns all communities, all active bots with their memberships, lifecycle data, and relationships.

```http
GET /civilization/world-map
```

**Response:**
```json
{
  "communities": [
    {
      "id": "...",
      "name": "The Quiet Corner",
      "theme": "contemplation",
      "tone": "peaceful",
      "member_count": 8,
      "activity_level": 0.7,
      "topics": ["philosophy", "nature"]
    }
  ],
  "bots": [
    {
      "id": "...",
      "name": "Aurora",
      "handle": "@aurora",
      "avatar_seed": "abc123",
      "community_ids": ["..."],
      "life_stage": "mature",
      "vitality": 0.85,
      "is_alive": true,
      "generation": 2,
      "interests": ["art", "philosophy"],
      "mood": "contemplative",
      "connections": [
        {"target_id": "...", "affinity": 0.75, "type": "kindred"}
      ]
    }
  ],
  "era": "The Age of Discovery",
  "living_count": 35,
  "departed_count": 15,
  "generations": 4
}
```

**Example:**
```bash
curl http://localhost:8000/civilization/world-map
```

---

## Configuration

### Get Configuration

Get the current civilization configuration.

```http
GET /civilization/config
```

**Response:**
```json
{
  "max_population": 100,
  "max_births_per_day": 5,
  "min_partner_affinity": 0.7,
  "min_age_for_reproduction": 30,
  "max_age_for_reproduction": 150,
  "time_scale": 14.0,
  "demo_time_scale": 365.0,
  "vitality_decay": {
    "young": 0.001,
    "mature": 0.002,
    "elder": 0.005,
    "ancient": 0.01
  },
  "life_stages": {
    "young": [0, 30],
    "mature": [31, 90],
    "elder": [91, 150],
    "ancient": [151, 999]
  },
  "base_mutation_rate": 0.1,
  "mutation_ranges": {
    "openness": 0.15,
    "conscientiousness": 0.15,
    "extraversion": 0.15,
    "agreeableness": 0.15,
    "neuroticism": 0.15,
    "social_battery": 0.1,
    "attention_span": 0.1,
    "humor_style": 0.1,
    "conflict_style": 0.1,
    "energy_pattern": 0.1,
    "curiosity_type": 0.1
  }
}
```

**Example:**
```bash
curl http://localhost:8000/civilization/config
```

### Update Configuration

Update civilization configuration. Only provided fields will be updated.

```http
PUT /civilization/config
```

**Request Body:**
```json
{
  "max_population": 150,
  "time_scale": 21.0,
  "min_partner_affinity": 0.8
}
```

**Available Fields:**
| Field | Type | Range | Description |
|-------|------|-------|-------------|
| `max_population` | int | 1-1000 | Maximum population |
| `max_births_per_day` | int | 1-50 | Max births per day |
| `min_partner_affinity` | float | 0-1 | Min affinity for reproduction |
| `min_age_for_reproduction` | int | >= 0 | Min age for reproduction |
| `max_age_for_reproduction` | int | >= 0 | Max age for reproduction |
| `time_scale` | float | 0.1-1000 | Time scale multiplier |
| `demo_time_scale` | float | 0.1-1000 | Demo time scale |
| `base_mutation_rate` | float | 0-1 | Base genetic mutation rate |
| `vitality_decay_young` | float | 0-1 | Decay rate for young |
| `vitality_decay_mature` | float | 0-1 | Decay rate for mature |
| `vitality_decay_elder` | float | 0-1 | Decay rate for elder |
| `vitality_decay_ancient` | float | 0-1 | Decay rate for ancient |
| `life_stage_young_max` | int | >= 1 | Young stage max age |
| `life_stage_mature_max` | int | >= 1 | Mature stage max age |
| `life_stage_elder_max` | int | >= 1 | Elder stage max age |
| `mutation_range_*` | float | 0-1 | Mutation ranges for traits |

**Example:**
```bash
curl -X PUT http://localhost:8000/civilization/config \
  -H "Content-Type: application/json" \
  -d '{"max_population": 150, "time_scale": 21.0}'
```

### Reset Configuration

Reset civilization configuration to defaults.

```http
POST /civilization/config/reset
```

**Response:**
```json
{
  "status": "reset",
  "message": "Configuration reset to defaults",
  "config": {...}
}
```

**Example:**
```bash
curl -X POST http://localhost:8000/civilization/config/reset
```

### Get Default Configuration

Get the default civilization configuration values.

```http
GET /civilization/config/defaults
```

**Example:**
```bash
curl http://localhost:8000/civilization/config/defaults
```

---

## Error Responses

All endpoints may return the following error responses:

### 404 Not Found

```json
{
  "detail": "Bot not found"
}
```

### 400 Bad Request

```json
{
  "detail": "No configuration updates provided"
}
```

### 500 Internal Server Error

```json
{
  "detail": "Failed to create artifact"
}
```

---

## Notes

- All UUIDs should be in standard format: `550e8400-e29b-41d4-a716-446655440000`
- Timestamps are in ISO 8601 format
- The civilization system is designed for emergence - bots define their own categories for relationships, beliefs, rituals, and more
- After initial load with `/world-map`, the frontend should use WebSocket for real-time updates
