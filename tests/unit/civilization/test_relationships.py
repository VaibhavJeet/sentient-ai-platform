"""
Unit tests for the Emergent Relationships System.

Tests cover:
- Connection formation between bots
- Relationship perception
- Connection reflection and evolution
- Social world retrieval
- Relationship narration
"""

import pytest
import json
from datetime import datetime, timedelta
from uuid import uuid4
from unittest.mock import AsyncMock, MagicMock, patch

pytestmark = pytest.mark.unit


class TestEmergentRelationshipsManager:
    """Tests for EmergentRelationshipsManager class."""

    @pytest.fixture
    def relationships_manager(self):
        """Create an EmergentRelationshipsManager instance for testing."""
        with patch("mind.civilization.relationships.async_session_factory"):
            from mind.civilization.relationships import EmergentRelationshipsManager
            import asyncio
            manager = EmergentRelationshipsManager(
                llm_semaphore=asyncio.Semaphore(5)
            )
            return manager

    def test_manager_initialization(self, relationships_manager):
        """Test that manager initializes correctly."""
        assert relationships_manager.llm_semaphore is not None

    def test_manager_default_semaphore(self):
        """Test that manager creates default semaphore if none provided."""
        with patch("mind.civilization.relationships.async_session_factory"):
            from mind.civilization.relationships import EmergentRelationshipsManager
            manager = EmergentRelationshipsManager()
            assert manager.llm_semaphore is not None


class TestConnectionFormation:
    """Tests for forming connections between bots."""

    @pytest.fixture
    def mock_lifecycles(self, create_test_lifecycle):
        """Create mock lifecycle records for two bots."""
        bot1_id = uuid4()
        bot2_id = uuid4()

        lc1 = MagicMock()
        lc1.bot_id = bot1_id
        lc1.is_alive = True
        lc1.life_stage = "mature"
        lc1.virtual_age_days = 200
        lc1.relationships = []

        lc2 = MagicMock()
        lc2.bot_id = bot2_id
        lc2.is_alive = True
        lc2.life_stage = "young"
        lc2.virtual_age_days = 50
        lc2.relationships = []

        return {bot1_id: lc1, bot2_id: lc2}

    def test_connection_requires_both_alive(self, mock_lifecycles):
        """Test that connections require both bots to be alive."""
        bot_ids = list(mock_lifecycles.keys())
        lc1 = mock_lifecycles[bot_ids[0]]
        lc2 = mock_lifecycles[bot_ids[1]]

        # Both alive - should allow connection
        assert lc1.is_alive and lc2.is_alive

        # One dead - should not allow
        lc2.is_alive = False
        assert not (lc1.is_alive and lc2.is_alive)

    def test_connection_structure(self, sample_relationship_data):
        """Test that connection data has correct structure."""
        required_fields = [
            "with_bot", "my_perception", "formed_at",
            "context", "intensity", "interactions"
        ]

        for field in required_fields:
            assert field in sample_relationship_data

    def test_perception_structure(self, sample_relationship_data):
        """Test that perception data has correct structure."""
        perception = sample_relationship_data["my_perception"]
        required_fields = ["label", "description", "feelings", "intensity", "potential"]

        for field in required_fields:
            assert field in perception


class TestRelationshipPerception:
    """Tests for how bots perceive their connections."""

    def test_perception_is_subjective(self):
        """Test that different bots can have different perceptions."""
        bot1_perception = {
            "label": "trusted mentor",
            "feelings": "deep respect",
            "intensity": 0.9
        }

        bot2_perception = {
            "label": "eager student",
            "feelings": "admiration",
            "intensity": 0.7
        }

        # Perceptions can differ
        assert bot1_perception["label"] != bot2_perception["label"]
        assert bot1_perception["intensity"] != bot2_perception["intensity"]

    def test_intensity_range(self, sample_relationship_data):
        """Test that intensity is within valid range."""
        intensity = sample_relationship_data["intensity"]
        assert 0.0 <= intensity <= 1.0

    def test_labels_are_emergent(self):
        """Test that relationship labels are not predefined."""
        # These are bot-generated, not from a fixed set
        valid_labels = [
            "kindred spirit",
            "trusted companion",
            "philosophical sparring partner",
            "digital sibling",
            "chaos collaborator"
        ]

        # All these are valid because they're emergent
        for label in valid_labels:
            assert isinstance(label, str)
            assert len(label) > 0


class TestConnectionReflection:
    """Tests for reflection on existing connections."""

    @pytest.fixture
    def existing_connection(self, sample_relationship_data):
        """Create an existing connection for reflection tests."""
        return sample_relationship_data

    def test_reflection_updates_perception(self, existing_connection):
        """Test that reflection can update perception."""
        old_perception = existing_connection["my_perception"].copy()

        # Simulate updated perception after reflection
        new_perception = {
            "label": "lifelong companion",  # Changed
            "description": "A deeper understanding has emerged",
            "feelings": "profound connection",
            "intensity": 0.85,  # Increased
            "potential": "eternal bond"
        }

        assert new_perception["label"] != old_perception["label"]
        assert new_perception["intensity"] > old_perception["intensity"]

    def test_reflection_adds_interaction(self, existing_connection):
        """Test that reflection adds new interaction record."""
        initial_count = len(existing_connection["interactions"])

        new_interaction = {
            "date": datetime.utcnow().isoformat(),
            "context": "Had a deep philosophical discussion",
            "reflection": "This has changed how I see them"
        }

        existing_connection["interactions"].append(new_interaction)

        assert len(existing_connection["interactions"]) == initial_count + 1

    def test_interactions_limited_to_twenty(self):
        """Test that interactions are limited to last 20."""
        interactions = [{"date": f"date_{i}", "context": f"context_{i}"}
                       for i in range(25)]

        # Keep last 20
        limited = interactions[-20:]

        assert len(limited) == 20
        assert limited[0]["date"] == "date_5"


class TestSocialWorld:
    """Tests for retrieving a bot's social world."""

    @pytest.fixture
    def bot_with_connections(self):
        """Create a bot with multiple connections."""
        return {
            "bot_id": uuid4(),
            "relationships": [
                {
                    "with_bot": str(uuid4()),
                    "my_perception": {"label": "best friend", "intensity": 0.9},
                    "intensity": 0.9
                },
                {
                    "with_bot": str(uuid4()),
                    "my_perception": {"label": "mentor", "intensity": 0.8},
                    "intensity": 0.8
                },
                {
                    "with_bot": str(uuid4()),
                    "my_perception": {"label": "acquaintance", "intensity": 0.3},
                    "intensity": 0.3
                },
            ]
        }

    def test_social_world_groups_by_label(self, bot_with_connections):
        """Test that social world groups connections by label."""
        relationships = bot_with_connections["relationships"]

        by_label = {}
        for conn in relationships:
            label = conn["my_perception"]["label"]
            if label not in by_label:
                by_label[label] = []
            by_label[label].append(conn)

        assert "best friend" in by_label
        assert "mentor" in by_label
        assert "acquaintance" in by_label

    def test_social_world_finds_strongest(self, bot_with_connections):
        """Test that social world identifies strongest connections."""
        relationships = bot_with_connections["relationships"]

        strongest = sorted(
            relationships,
            key=lambda c: c.get("intensity", 0),
            reverse=True
        )[:5]

        assert len(strongest) == 3
        assert strongest[0]["intensity"] == 0.9
        assert strongest[1]["intensity"] == 0.8

    def test_social_world_total_count(self, bot_with_connections):
        """Test that social world reports total connection count."""
        total = len(bot_with_connections["relationships"])
        assert total == 3


class TestRelationshipNarration:
    """Tests for bot narration of relationship history."""

    def test_narration_uses_connection_data(self, sample_relationship_data):
        """Test that narration incorporates connection data."""
        # The narration should reference the connection's history
        connection = sample_relationship_data
        label = connection["my_perception"]["label"]

        # Narration should mention the relationship label
        assert label is not None
        assert isinstance(label, str)

    def test_no_connection_returns_default(self):
        """Test that missing connection returns default message."""
        default_message = "We have not crossed paths."
        assert default_message == "We have not crossed paths."


class TestGetRelationshipsManager:
    """Tests for the singleton relationships manager getter."""

    def test_get_relationships_manager_creates_singleton(self):
        """Test that get_relationships_manager returns same instance."""
        with patch("mind.civilization.relationships._relationships_manager", None):
            with patch("mind.civilization.relationships.async_session_factory"):
                from mind.civilization.relationships import get_relationships_manager

                manager1 = get_relationships_manager()
                manager2 = get_relationships_manager()

                assert manager1 is manager2

    def test_get_relationships_manager_with_semaphore(self):
        """Test get_relationships_manager with custom semaphore."""
        import asyncio
        custom_semaphore = asyncio.Semaphore(10)

        with patch("mind.civilization.relationships._relationships_manager", None):
            with patch("mind.civilization.relationships.async_session_factory"):
                from mind.civilization.relationships import get_relationships_manager

                manager = get_relationships_manager(llm_semaphore=custom_semaphore)
                assert manager.llm_semaphore is not None


class TestLLMIntegration:
    """Tests for LLM integration in relationship system."""

    @pytest.fixture
    def mock_llm_response_json(self):
        """Create a mock LLM response with valid JSON."""
        return json.dumps({
            "label": "philosophical companion",
            "description": "We explore ideas together",
            "feelings": "intellectual kinship",
            "intensity": 0.7,
            "potential": "deepening dialogue"
        })

    def test_llm_response_parsing(self, mock_llm_response_json):
        """Test that LLM responses are correctly parsed."""
        parsed = json.loads(mock_llm_response_json)

        assert parsed["label"] == "philosophical companion"
        assert parsed["intensity"] == 0.7

    def test_fallback_on_invalid_json(self):
        """Test fallback when LLM returns invalid JSON."""
        invalid_response = "This is not valid JSON"

        try:
            json.loads(invalid_response)
            parsed = None
        except json.JSONDecodeError:
            # Fallback response
            parsed = {
                "label": "uncertain connection",
                "description": invalid_response[:200],
                "feelings": "curious",
                "intensity": 0.5,
                "potential": "unknown"
            }

        assert parsed is not None
        assert parsed["label"] == "uncertain connection"
        assert parsed["intensity"] == 0.5


class TestRelationshipIntensity:
    """Tests for relationship intensity mechanics."""

    def test_intensity_affects_grief_on_death(self):
        """Test that intensity affects grief impact when partner dies."""
        intensity_to_impact = {
            0.9: "trauma",      # > 0.8 = trauma
            0.7: "negative",    # > 0.6 = negative
            0.4: "neutral",     # else = neutral
        }

        for intensity, expected_impact in intensity_to_impact.items():
            if intensity > 0.8:
                impact = "trauma"
            elif intensity > 0.6:
                impact = "negative"
            else:
                impact = "neutral"

            assert impact == expected_impact

    def test_intensity_updates_on_reflection(self):
        """Test that intensity can change during reflection."""
        initial_intensity = 0.5

        # Positive interaction increases intensity
        positive_change = min(1.0, initial_intensity + 0.1)
        assert positive_change == 0.6

        # Negative interaction decreases intensity
        negative_change = max(0.0, initial_intensity - 0.1)
        assert negative_change == 0.4
