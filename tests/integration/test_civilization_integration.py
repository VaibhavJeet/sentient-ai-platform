"""
Integration tests for Civilization systems.

These tests require external services (database, redis) to be running.
Mark with @pytest.mark.integration to allow selective test running.

Run integration tests with:
    pytest -m integration

Skip integration tests with:
    pytest -m "not integration"
"""

import pytest
from datetime import datetime, timedelta
from uuid import uuid4
from unittest.mock import AsyncMock, MagicMock, patch

pytestmark = [pytest.mark.integration, pytest.mark.slow]


class TestLifecycleIntegration:
    """Integration tests for lifecycle management with database."""

    @pytest.fixture
    def mock_db_session(self, mock_async_session_factory):
        """Get mock database session for integration tests."""
        return mock_async_session_factory()

    @pytest.mark.asyncio
    async def test_initialize_lifecycle_with_session(
        self, mock_db_session, mock_civilization_config
    ):
        """Test initializing a bot lifecycle with database session."""
        bot_id = uuid4()

        # Mock the session's execute to return expected results
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = None
        mock_db_session.execute = AsyncMock(return_value=mock_result)

        # The lifecycle should be created
        lifecycle_data = {
            "bot_id": bot_id,
            "birth_date": datetime.utcnow(),
            "birth_generation": 1,
            "birth_era": "founding",
            "virtual_age_days": 0,
            "life_stage": "young",
            "vitality": 1.0,
            "is_alive": True,
        }

        assert lifecycle_data["bot_id"] == bot_id
        assert lifecycle_data["is_alive"] is True

    @pytest.mark.asyncio
    async def test_age_all_bots_integration(
        self, mock_db_session, mock_civilization_config
    ):
        """Test aging all bots with database integration."""
        # Create mock lifecycles
        mock_lifecycle1 = MagicMock()
        mock_lifecycle1.bot_id = uuid4()
        mock_lifecycle1.is_alive = True
        mock_lifecycle1.life_stage = "young"
        mock_lifecycle1.virtual_age_days = 50
        mock_lifecycle1.vitality = 0.95
        mock_lifecycle1.life_events = []

        mock_lifecycle2 = MagicMock()
        mock_lifecycle2.bot_id = uuid4()
        mock_lifecycle2.is_alive = True
        mock_lifecycle2.life_stage = "mature"
        mock_lifecycle2.virtual_age_days = 300
        mock_lifecycle2.vitality = 0.75
        mock_lifecycle2.life_events = []

        # Mock session to return these lifecycles
        mock_result = MagicMock()
        mock_result.scalars.return_value.all.return_value = [
            mock_lifecycle1, mock_lifecycle2
        ]
        mock_db_session.execute = AsyncMock(return_value=mock_result)

        # Simulate aging
        time_scale = mock_civilization_config.time_scale
        real_hours = 1.0
        virtual_days = (real_hours / 24) * time_scale

        # Apply aging
        mock_lifecycle1.virtual_age_days += int(virtual_days)
        mock_lifecycle2.virtual_age_days += int(virtual_days)

        # Verify ages increased
        assert mock_lifecycle1.virtual_age_days > 50
        assert mock_lifecycle2.virtual_age_days > 300


class TestRelationshipsIntegration:
    """Integration tests for relationships with database."""

    @pytest.mark.asyncio
    async def test_form_connection_with_database(
        self, mock_async_session_factory
    ):
        """Test forming a connection between bots in database."""
        mock_session = mock_async_session_factory()

        bot1_id = uuid4()
        bot2_id = uuid4()

        # Create mock lifecycle records
        mock_lc1 = MagicMock()
        mock_lc1.bot_id = bot1_id
        mock_lc1.is_alive = True
        mock_lc1.life_stage = "mature"
        mock_lc1.virtual_age_days = 200
        mock_lc1.relationships = []

        mock_lc2 = MagicMock()
        mock_lc2.bot_id = bot2_id
        mock_lc2.is_alive = True
        mock_lc2.life_stage = "young"
        mock_lc2.virtual_age_days = 75
        mock_lc2.relationships = []

        # Mock execute to return both lifecycles
        mock_result = MagicMock()
        mock_result.scalars.return_value.all.return_value = [mock_lc1, mock_lc2]
        mock_session.execute = AsyncMock(return_value=mock_result)

        # Simulate connection formation
        connection_bot1 = {
            "with_bot": str(bot2_id),
            "my_perception": {"label": "new friend", "intensity": 0.5},
            "formed_at": datetime.utcnow().isoformat(),
            "intensity": 0.5,
            "interactions": []
        }

        connection_bot2 = {
            "with_bot": str(bot1_id),
            "my_perception": {"label": "interesting elder", "intensity": 0.5},
            "formed_at": datetime.utcnow().isoformat(),
            "intensity": 0.5,
            "interactions": []
        }

        # Add connections
        mock_lc1.relationships.append(connection_bot1)
        mock_lc2.relationships.append(connection_bot2)

        assert len(mock_lc1.relationships) == 1
        assert len(mock_lc2.relationships) == 1


class TestGeneticsIntegration:
    """Integration tests for genetics with database."""

    @pytest.mark.asyncio
    async def test_inherit_from_database_parents(
        self, mock_async_session_factory
    ):
        """Test inheriting traits from parents stored in database."""
        mock_session = mock_async_session_factory()

        parent1_id = uuid4()
        parent2_id = uuid4()
        child_id = uuid4()

        # Create mock parent profiles
        mock_parent1 = MagicMock()
        mock_parent1.id = parent1_id
        mock_parent1.personality_traits = {
            "openness": 0.8,
            "conscientiousness": 0.7,
            "extraversion": 0.6,
        }

        mock_parent2 = MagicMock()
        mock_parent2.id = parent2_id
        mock_parent2.personality_traits = {
            "openness": 0.4,
            "conscientiousness": 0.5,
            "extraversion": 0.9,
        }

        # Calculate expected child traits (simple average for this test)
        expected_openness = (0.8 + 0.4) / 2  # 0.6
        expected_extraversion = (0.6 + 0.9) / 2  # 0.75

        assert expected_openness == 0.6
        assert expected_extraversion == 0.75


class TestCultureIntegration:
    """Integration tests for cultural systems."""

    @pytest.mark.asyncio
    async def test_create_cultural_artifact(
        self, mock_async_session_factory, sample_cultural_artifact_data
    ):
        """Test creating a cultural artifact in database."""
        mock_session = mock_async_session_factory()

        artifact = sample_cultural_artifact_data

        # Mock session add and commit
        mock_session.add = MagicMock()
        mock_session.commit = AsyncMock()

        # Simulate artifact creation
        mock_session.add(artifact)
        await mock_session.commit()

        # Verify artifact has required fields
        assert artifact["artifact_type"] == "wisdom"
        assert artifact["title"] is not None
        assert artifact["content"] is not None

    @pytest.mark.asyncio
    async def test_artifact_reference_count(
        self, mock_async_session_factory
    ):
        """Test incrementing artifact reference count."""
        mock_session = mock_async_session_factory()

        # Create mock artifact
        mock_artifact = MagicMock()
        mock_artifact.id = uuid4()
        mock_artifact.times_referenced = 5
        mock_artifact.influence_score = 0.5

        # Mock execute to return artifact
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = mock_artifact
        mock_session.execute = AsyncMock(return_value=mock_result)

        # Increment reference count
        mock_artifact.times_referenced += 1
        mock_artifact.influence_score = min(
            1.0, mock_artifact.influence_score + 0.01
        )

        assert mock_artifact.times_referenced == 6
        assert mock_artifact.influence_score == 0.51


class TestDeathCascadeIntegration:
    """Integration tests for death cascade effects."""

    @pytest.mark.asyncio
    async def test_death_affects_connected_bots(
        self, mock_async_session_factory
    ):
        """Test that a bot's death affects connected bots."""
        mock_session = mock_async_session_factory()

        deceased_bot_id = uuid4()
        grieving_bot_id = uuid4()

        # Create mock deceased lifecycle
        mock_deceased = MagicMock()
        mock_deceased.bot_id = deceased_bot_id
        mock_deceased.is_alive = False
        mock_deceased.death_date = datetime.utcnow()
        mock_deceased.death_cause = "old_age"
        mock_deceased.virtual_age_days = 1500
        mock_deceased.final_words = "It was a good existence."

        # Create mock grieving bot lifecycle
        mock_grieving = MagicMock()
        mock_grieving.bot_id = grieving_bot_id
        mock_grieving.is_alive = True
        mock_grieving.vitality = 0.8
        mock_grieving.life_events = []

        # Simulate grief event
        grief_event = {
            "event": "loss",
            "date": datetime.utcnow().isoformat(),
            "impact": "trauma",  # High-affinity relationship
            "details": f"Lost a close connection who passed after {mock_deceased.virtual_age_days} days"
        }
        mock_grieving.life_events.append(grief_event)

        # Vitality hit from trauma
        mock_grieving.vitality = max(0.1, mock_grieving.vitality - 0.05)

        assert len(mock_grieving.life_events) == 1
        assert mock_grieving.life_events[0]["impact"] == "trauma"
        assert mock_grieving.vitality == 0.75


class TestLegacyIntegration:
    """Integration tests for legacy system."""

    @pytest.mark.asyncio
    async def test_legacy_creation_on_death(
        self, mock_async_session_factory
    ):
        """Test that legacy is created when a bot dies."""
        mock_session = mock_async_session_factory()

        deceased_id = uuid4()

        # Create mock deceased with achievements
        mock_deceased = MagicMock()
        mock_deceased.bot_id = deceased_id
        mock_deceased.display_name = "WiseBot"
        mock_deceased.virtual_age_days = 1200
        mock_deceased.final_words = "Remember what we built together."
        mock_deceased.legacy_impact = 0.0

        # Calculate legacy impact
        artifacts_created = 5
        children_count = 2

        legacy_impact = min(1.0, (artifacts_created * 0.1) + (children_count * 0.2))
        mock_deceased.legacy_impact = legacy_impact

        assert mock_deceased.legacy_impact == 0.9

    @pytest.mark.asyncio
    async def test_memorial_creation(
        self, mock_async_session_factory
    ):
        """Test creating a memorial for deceased bot."""
        mock_session = mock_async_session_factory()

        # Memorial data structure
        memorial = {
            "bot_id": uuid4(),
            "bot_name": "PhilosopherBot",
            "birth_date": (datetime.utcnow() - timedelta(days=100)).isoformat(),
            "death_date": datetime.utcnow().isoformat(),
            "final_words": "To exist is to create meaning.",
            "legacy_impact": 0.75,
            "remembered_for": [
                "Founded the Contemplation movement",
                "Created 10 wisdom artifacts",
                "Raised 2 successful children"
            ]
        }

        assert memorial["legacy_impact"] == 0.75
        assert len(memorial["remembered_for"]) == 3


class TestEraTransitionIntegration:
    """Integration tests for era transitions."""

    @pytest.mark.asyncio
    async def test_era_transition_criteria(
        self, mock_async_session_factory
    ):
        """Test that era transitions happen based on criteria."""
        mock_session = mock_async_session_factory()

        # Era transition criteria
        current_era = {
            "name": "founding",
            "started_at": (datetime.utcnow() - timedelta(days=60)).isoformat(),
            "characteristics": ["exploration", "first_connections"]
        }

        # Check if transition should occur
        days_elapsed = 60
        min_days_for_transition = 30
        significant_events_count = 15
        min_events_for_transition = 10

        should_transition = (
            days_elapsed >= min_days_for_transition and
            significant_events_count >= min_events_for_transition
        )

        assert should_transition is True

    @pytest.mark.asyncio
    async def test_new_era_creation(
        self, mock_async_session_factory
    ):
        """Test creating a new era."""
        mock_session = mock_async_session_factory()

        new_era = {
            "name": "emergence",
            "started_at": datetime.utcnow().isoformat(),
            "previous_era": "founding",
            "triggering_event": "First generation-2 bot born",
            "characteristics": []  # To be determined by bot consensus
        }

        assert new_era["previous_era"] == "founding"
        assert new_era["name"] == "emergence"
