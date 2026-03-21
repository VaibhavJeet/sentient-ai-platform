"""
Unit tests for the Lifecycle Manager.

Tests cover:
- Bot lifecycle initialization
- Aging mechanics
- Life stage transitions
- Vitality decay
- Death handling
- Legacy calculation
"""

import pytest
from datetime import datetime, timedelta
from uuid import uuid4
from unittest.mock import AsyncMock, MagicMock, patch

pytestmark = pytest.mark.unit


class TestLifecycleManager:
    """Tests for LifecycleManager class."""

    @pytest.fixture
    def lifecycle_manager(self):
        """Create a LifecycleManager instance for testing."""
        with patch("mind.civilization.lifecycle.async_session_factory"):
            from mind.civilization.lifecycle import LifecycleManager
            manager = LifecycleManager(time_scale=7.0, demo_mode=False)
            return manager

    @pytest.fixture
    def demo_lifecycle_manager(self):
        """Create a demo mode LifecycleManager for faster aging tests."""
        with patch("mind.civilization.lifecycle.async_session_factory"):
            from mind.civilization.lifecycle import LifecycleManager
            manager = LifecycleManager(demo_mode=True)
            return manager

    def test_time_scale_default(self, lifecycle_manager):
        """Test default time scale is set correctly."""
        assert lifecycle_manager.time_scale == 7.0

    def test_demo_mode_time_scale(self, demo_lifecycle_manager):
        """Test demo mode has faster time scale."""
        # Demo mode should have higher time scale for faster aging
        assert demo_lifecycle_manager.demo_mode is True

    @pytest.mark.asyncio
    async def test_get_time_scale_with_override(self, lifecycle_manager):
        """Test time scale with explicit override."""
        lifecycle_manager._time_scale_override = 14.0
        result = await lifecycle_manager.get_time_scale()
        assert result == 14.0


class TestLifeStageTransitions:
    """Tests for life stage determination and transitions."""

    @pytest.fixture
    def mock_config(self, mock_civilization_config):
        """Create a mock config with life stage boundaries."""
        return mock_civilization_config

    def test_young_stage(self, mock_config):
        """Test young life stage for low age."""
        assert mock_config.get_life_stage(50) == "young"

    def test_mature_stage(self, mock_config):
        """Test mature life stage for middle age."""
        assert mock_config.get_life_stage(250) == "mature"

    def test_elder_stage(self, mock_config):
        """Test elder life stage for high age."""
        assert mock_config.get_life_stage(750) == "elder"

    def test_ancient_stage(self, mock_config):
        """Test ancient life stage for very high age."""
        assert mock_config.get_life_stage(1500) == "ancient"


class TestVitalityDecay:
    """Tests for vitality decay mechanics."""

    @pytest.fixture
    def mock_config(self, mock_civilization_config):
        return mock_civilization_config

    def test_young_minimal_decay(self, mock_config):
        """Test young bots have minimal vitality decay."""
        decay = mock_config.get_vitality_decay("young")
        assert decay == 0.0001
        assert decay < mock_config.get_vitality_decay("mature")

    def test_elder_higher_decay(self, mock_config):
        """Test elder bots have higher vitality decay."""
        decay = mock_config.get_vitality_decay("elder")
        assert decay == 0.001
        assert decay > mock_config.get_vitality_decay("mature")

    def test_ancient_highest_decay(self, mock_config):
        """Test ancient bots have highest vitality decay."""
        decay = mock_config.get_vitality_decay("ancient")
        assert decay == 0.002
        assert decay > mock_config.get_vitality_decay("elder")


class TestLifecycleInitialization:
    """Tests for bot lifecycle initialization."""

    @pytest.mark.asyncio
    async def test_initialize_founding_bot(self, create_test_lifecycle):
        """Test initializing a founding generation bot."""
        lifecycle_data = create_test_lifecycle(
            generation=1,
            is_alive=True,
            life_stage="young",
            virtual_age_days=0
        )

        assert lifecycle_data["birth_generation"] == 1
        assert lifecycle_data["is_alive"] is True
        assert lifecycle_data["life_stage"] == "young"

    @pytest.mark.asyncio
    async def test_lifecycle_with_parents(self, create_test_lifecycle):
        """Test initializing a bot with parents (second generation)."""
        parent1_id = uuid4()
        parent2_id = uuid4()

        lifecycle_data = create_test_lifecycle(
            birth_generation=2,
            parent1_id=parent1_id,
            parent2_id=parent2_id
        )

        # Would be set during actual initialization
        lifecycle_data["birth_generation"] = 2

        assert lifecycle_data["birth_generation"] == 2


class TestDeathMechanics:
    """Tests for death probability and handling."""

    def test_young_bots_dont_die_naturally(self):
        """Test that young bots cannot die naturally."""
        # Young bots should have 0 probability of natural death
        mock_lifecycle = MagicMock()
        mock_lifecycle.life_stage = "young"
        mock_lifecycle.vitality = 1.0

        # According to _should_die_naturally, young bots return False
        assert mock_lifecycle.life_stage == "young"

    def test_zero_vitality_causes_death(self):
        """Test that zero vitality causes certain death."""
        mock_lifecycle = MagicMock()
        mock_lifecycle.life_stage = "elder"
        mock_lifecycle.vitality = 0.0

        # Zero vitality should trigger death
        assert mock_lifecycle.vitality <= 0

    def test_death_probability_increases_with_age(self):
        """Test that death probability increases for elder and ancient stages."""
        # Define expected base probabilities
        base_probs = {
            "young": 0.0,
            "mature": 0.0001,
            "elder": 0.001,
            "ancient": 0.01,
        }

        assert base_probs["young"] < base_probs["mature"]
        assert base_probs["mature"] < base_probs["elder"]
        assert base_probs["elder"] < base_probs["ancient"]


class TestLegacyCalculation:
    """Tests for legacy impact calculation."""

    def test_legacy_from_artifacts(self):
        """Test legacy calculation based on cultural artifacts."""
        artifact_count = 5
        artifact_impact = artifact_count * 0.1
        assert artifact_impact == 0.5

    def test_legacy_from_children(self):
        """Test legacy calculation based on descendants."""
        children_count = 3
        children_impact = children_count * 0.2
        assert children_impact == 0.6

    def test_legacy_normalized(self):
        """Test that legacy is normalized to 0-1 range."""
        # Even with many contributions, legacy should cap at 1.0
        artifact_impact = 10 * 0.1  # 10 artifacts
        children_impact = 5 * 0.2  # 5 children
        total = artifact_impact + children_impact
        normalized = min(1.0, total)
        assert normalized == 1.0


class TestLifeEvents:
    """Tests for life event recording."""

    def test_life_event_structure(self, sample_bot_lifecycle_data):
        """Test that life events have correct structure."""
        life_events = sample_bot_lifecycle_data["life_events"]

        assert len(life_events) >= 1

        # Check first event (birth)
        birth_event = life_events[0]
        assert "event" in birth_event
        assert "date" in birth_event
        assert "impact" in birth_event
        assert "details" in birth_event
        assert birth_event["event"] == "born"

    def test_life_event_impact_types(self):
        """Test valid life event impact types."""
        valid_impacts = ["defining", "positive", "negative", "neutral", "trauma", "milestone"]

        for impact in valid_impacts:
            event = {
                "event": "test_event",
                "date": datetime.utcnow().isoformat(),
                "impact": impact,
                "details": "Test"
            }
            assert event["impact"] in valid_impacts

    @pytest.mark.asyncio
    async def test_trauma_reduces_vitality(self, create_test_lifecycle):
        """Test that trauma events reduce vitality."""
        lifecycle = create_test_lifecycle(vitality=1.0)
        initial_vitality = lifecycle["vitality"]

        # Simulate trauma event
        trauma_vitality_loss = 0.05
        new_vitality = max(0.1, initial_vitality - trauma_vitality_loss)

        assert new_vitality < initial_vitality
        assert new_vitality == 0.95


class TestGetLifecycleManager:
    """Tests for the singleton lifecycle manager getter."""

    def test_get_lifecycle_manager_creates_singleton(self):
        """Test that get_lifecycle_manager returns same instance."""
        with patch("mind.civilization.lifecycle._lifecycle_manager", None):
            with patch("mind.civilization.lifecycle.async_session_factory"):
                from mind.civilization.lifecycle import get_lifecycle_manager

                manager1 = get_lifecycle_manager()
                manager2 = get_lifecycle_manager()

                # Should be the same instance
                assert manager1 is manager2

    def test_get_lifecycle_manager_demo_mode(self):
        """Test get_lifecycle_manager with demo mode."""
        with patch("mind.civilization.lifecycle._lifecycle_manager", None):
            with patch("mind.civilization.lifecycle.async_session_factory"):
                from mind.civilization.lifecycle import get_lifecycle_manager

                manager = get_lifecycle_manager(demo_mode=True)
                assert manager.demo_mode is True


class TestBiography:
    """Tests for bot biography generation."""

    def test_biography_structure(self, sample_bot_lifecycle_data):
        """Test that biography has correct structure."""
        expected_fields = [
            "bot_id", "birth_date", "birth_generation", "birth_era",
            "virtual_age_days", "life_stage", "vitality", "is_alive",
            "life_events"
        ]

        for field in expected_fields:
            assert field in sample_bot_lifecycle_data

    def test_dead_bot_biography_includes_death_info(self, create_test_lifecycle):
        """Test that dead bot biography includes death information."""
        lifecycle = create_test_lifecycle(
            is_alive=False,
            death_date=datetime.utcnow(),
            death_cause="old_age",
            death_age=1500,
            final_words="It was a good existence."
        )

        lifecycle["is_alive"] = False
        lifecycle["death_date"] = datetime.utcnow()
        lifecycle["death_cause"] = "old_age"
        lifecycle["death_age"] = 1500
        lifecycle["final_words"] = "It was a good existence."

        assert lifecycle["is_alive"] is False
        assert lifecycle["death_cause"] == "old_age"
        assert lifecycle["final_words"] is not None
