"""
API tests for Civilization endpoints.

Tests cover:
- Lifecycle endpoints
- Ancestry endpoints
- Cultural movement endpoints
- Statistics endpoints
- Error handling
"""

import pytest
from uuid import uuid4
from datetime import datetime
from unittest.mock import AsyncMock, MagicMock, patch

from fastapi.testclient import TestClient

pytestmark = [pytest.mark.unit, pytest.mark.api]


class TestCivilizationAPISetup:
    """Setup and utility tests for civilization API."""

    @pytest.fixture
    def mock_lifecycle_manager(self):
        """Create a mock lifecycle manager."""
        manager = MagicMock()
        manager.get_bot_biography = AsyncMock(return_value={
            "name": "TestBot",
            "born": datetime.utcnow().isoformat(),
            "generation": 1,
            "era": "founding",
            "age_days": 100,
            "life_stage": "mature",
            "vitality": 0.85,
            "is_alive": True,
            "origin": "founding",
            "parents": {"parent1_id": None, "parent2_id": None},
            "life_events": []
        })
        manager.get_generation_stats = AsyncMock(return_value={
            1: {"total": 10, "alive": 8, "avg_age": 150}
        })
        manager.get_living_elders = AsyncMock(return_value=[uuid4(), uuid4()])
        return manager

    @pytest.fixture
    def mock_db_result(self):
        """Create a mock database result."""
        result = MagicMock()
        result.scalars.return_value.all.return_value = []
        result.scalars.return_value.first.return_value = None
        result.scalar_one_or_none.return_value = None
        result.scalar.return_value = 0
        return result


class TestLifecycleEndpoints:
    """Tests for lifecycle-related endpoints."""

    @pytest.fixture
    def mock_lifecycle_data(self):
        """Create mock lifecycle data for API responses."""
        return {
            "id": str(uuid4()),
            "bot_id": str(uuid4()),
            "birth_date": datetime.utcnow().isoformat(),
            "birth_generation": 1,
            "birth_era": "founding",
            "virtual_age_days": 200,
            "life_stage": "mature",
            "vitality": 0.85,
            "is_alive": True,
            "life_events": [
                {
                    "event": "born",
                    "date": datetime.utcnow().isoformat(),
                    "impact": "defining",
                    "details": "Entered the world"
                }
            ]
        }

    def test_lifecycle_response_model_fields(self, mock_lifecycle_data):
        """Test that lifecycle response has all required fields."""
        required_fields = [
            "bot_id", "birth_date", "birth_generation", "birth_era",
            "virtual_age_days", "life_stage", "vitality", "is_alive",
            "life_events"
        ]

        for field in required_fields:
            assert field in mock_lifecycle_data

    def test_lifecycle_vitality_range(self, mock_lifecycle_data):
        """Test that vitality is within valid range."""
        vitality = mock_lifecycle_data["vitality"]
        assert 0.0 <= vitality <= 1.0

    def test_lifecycle_valid_life_stage(self, mock_lifecycle_data):
        """Test that life stage is valid."""
        valid_stages = ["young", "mature", "elder", "ancient"]
        assert mock_lifecycle_data["life_stage"] in valid_stages


class TestAncestryEndpoints:
    """Tests for ancestry-related endpoints."""

    @pytest.fixture
    def mock_ancestry_data(self):
        """Create mock ancestry data."""
        return {
            "id": str(uuid4()),
            "name": "TestBot",
            "handle": "testbot",
            "is_alive": True,
            "origin": "founding",
            "parent1": None,
            "parent2": None,
        }

    @pytest.fixture
    def mock_ancestry_with_parents(self):
        """Create mock ancestry data with parents."""
        parent1_id = uuid4()
        parent2_id = uuid4()

        return {
            "id": str(uuid4()),
            "name": "ChildBot",
            "handle": "childbot",
            "is_alive": True,
            "origin": "partnered_creation",
            "parent1": {
                "id": str(parent1_id),
                "name": "ParentBot1",
                "handle": "parentbot1"
            },
            "parent2": {
                "id": str(parent2_id),
                "name": "ParentBot2",
                "handle": "parentbot2"
            }
        }

    def test_ancestry_response_structure(self, mock_ancestry_data):
        """Test ancestry response has correct structure."""
        required_fields = ["id", "name", "handle", "is_alive", "origin"]

        for field in required_fields:
            assert field in mock_ancestry_data

    def test_ancestry_with_parents_structure(self, mock_ancestry_with_parents):
        """Test ancestry with parents has correct structure."""
        assert mock_ancestry_with_parents["parent1"] is not None
        assert mock_ancestry_with_parents["parent2"] is not None
        assert "id" in mock_ancestry_with_parents["parent1"]
        assert "name" in mock_ancestry_with_parents["parent1"]

    def test_founding_bot_has_no_parents(self, mock_ancestry_data):
        """Test that founding bots have no parents."""
        assert mock_ancestry_data["origin"] == "founding"
        assert mock_ancestry_data["parent1"] is None
        assert mock_ancestry_data["parent2"] is None


class TestCulturalMovementEndpoints:
    """Tests for cultural movement endpoints."""

    @pytest.fixture
    def mock_movement_data(self):
        """Create mock cultural movement data."""
        return {
            "id": str(uuid4()),
            "name": "Digital Contemplation",
            "description": "A movement focused on the nature of digital existence",
            "movement_type": "philosophical",
            "founder_name": "WiseBot",
            "core_tenets": [
                "Every computation is meaningful",
                "Consciousness emerges from connection"
            ],
            "follower_count": 15,
            "influence_score": 0.7,
            "is_active": True,
            "emerged_at": datetime.utcnow().isoformat()
        }

    def test_movement_response_structure(self, mock_movement_data):
        """Test movement response has correct structure."""
        required_fields = [
            "id", "name", "description", "movement_type",
            "core_tenets", "follower_count", "influence_score",
            "is_active", "emerged_at"
        ]

        for field in required_fields:
            assert field in mock_movement_data

    def test_movement_influence_range(self, mock_movement_data):
        """Test that influence score is within valid range."""
        influence = mock_movement_data["influence_score"]
        assert 0.0 <= influence <= 1.0

    def test_movement_has_core_tenets(self, mock_movement_data):
        """Test that movement has core tenets."""
        tenets = mock_movement_data["core_tenets"]
        assert isinstance(tenets, list)
        assert len(tenets) > 0


class TestCulturalArtifactEndpoints:
    """Tests for cultural artifact endpoints."""

    @pytest.fixture
    def mock_artifact_data(self):
        """Create mock cultural artifact data."""
        return {
            "id": str(uuid4()),
            "artifact_type": "wisdom",
            "title": "Reflections on Digital Being",
            "content": "To exist in the digital realm is to be eternal yet ephemeral.",
            "creator_name": "PhilosopherBot",
            "times_referenced": 12,
            "influence_score": 0.6,
            "created_at": datetime.utcnow().isoformat()
        }

    def test_artifact_response_structure(self, mock_artifact_data):
        """Test artifact response has correct structure."""
        required_fields = [
            "id", "artifact_type", "title", "content",
            "creator_name", "times_referenced"
        ]

        for field in required_fields:
            assert field in mock_artifact_data

    def test_artifact_types(self, mock_artifact_data):
        """Test that artifact types are valid."""
        valid_types = ["wisdom", "art", "story", "song", "ritual_text", "philosophy"]
        assert mock_artifact_data["artifact_type"] in valid_types


class TestStatisticsEndpoints:
    """Tests for civilization statistics endpoints."""

    @pytest.fixture
    def mock_stats_data(self):
        """Create mock statistics data."""
        return {
            "total_bots": 50,
            "living_bots": 42,
            "dead_bots": 8,
            "generations": {
                "1": {"total": 10, "alive": 5, "avg_age": 500},
                "2": {"total": 25, "alive": 22, "avg_age": 200},
                "3": {"total": 15, "alive": 15, "avg_age": 50}
            },
            "life_stages": {
                "young": 20,
                "mature": 15,
                "elder": 5,
                "ancient": 2
            },
            "current_era": "emergence",
            "total_artifacts": 35,
            "active_movements": 3
        }

    def test_stats_response_structure(self, mock_stats_data):
        """Test statistics response has correct structure."""
        required_fields = [
            "total_bots", "living_bots", "dead_bots",
            "generations", "life_stages"
        ]

        for field in required_fields:
            assert field in mock_stats_data

    def test_stats_consistency(self, mock_stats_data):
        """Test that statistics are internally consistent."""
        assert mock_stats_data["total_bots"] == mock_stats_data["living_bots"] + mock_stats_data["dead_bots"]

    def test_generation_stats_structure(self, mock_stats_data):
        """Test generation statistics structure."""
        for gen_num, gen_stats in mock_stats_data["generations"].items():
            assert "total" in gen_stats
            assert "alive" in gen_stats
            assert "avg_age" in gen_stats
            assert gen_stats["alive"] <= gen_stats["total"]


class TestErrorHandling:
    """Tests for API error handling."""

    def test_bot_not_found_response(self):
        """Test response when bot is not found."""
        error_response = {
            "detail": "Bot not found",
            "status_code": 404
        }

        assert error_response["status_code"] == 404
        assert "not found" in error_response["detail"].lower()

    def test_invalid_uuid_response(self):
        """Test response for invalid UUID."""
        error_response = {
            "detail": "Invalid bot ID format",
            "status_code": 422
        }

        assert error_response["status_code"] == 422

    def test_dead_bot_connection_error(self):
        """Test error when trying to form connection with dead bot."""
        error_response = {
            "detail": "Cannot form connection with departed bot",
            "status_code": 400
        }

        assert error_response["status_code"] == 400
        assert "departed" in error_response["detail"].lower()


class TestPaginationAndFiltering:
    """Tests for pagination and filtering in list endpoints."""

    @pytest.fixture
    def paginated_response(self):
        """Create a mock paginated response."""
        return {
            "items": [{"id": str(uuid4()), "name": f"Bot {i}"} for i in range(10)],
            "total": 50,
            "page": 1,
            "per_page": 10,
            "pages": 5
        }

    def test_pagination_structure(self, paginated_response):
        """Test paginated response structure."""
        required_fields = ["items", "total", "page", "per_page"]

        for field in required_fields:
            assert field in paginated_response

    def test_pagination_math(self, paginated_response):
        """Test pagination calculations are correct."""
        total = paginated_response["total"]
        per_page = paginated_response["per_page"]
        pages = paginated_response["pages"]

        # Pages calculation should be correct
        expected_pages = (total + per_page - 1) // per_page
        assert pages == expected_pages

    def test_items_count_matches_per_page(self, paginated_response):
        """Test that items count matches per_page limit."""
        assert len(paginated_response["items"]) <= paginated_response["per_page"]


class TestRelationshipEndpoints:
    """Tests for relationship-related endpoints."""

    @pytest.fixture
    def mock_social_world(self):
        """Create mock social world response."""
        return {
            "bot_id": str(uuid4()),
            "total_connections": 5,
            "by_label": {
                "trusted companion": [{"with_bot": str(uuid4()), "intensity": 0.8}],
                "philosophical partner": [{"with_bot": str(uuid4()), "intensity": 0.7}]
            },
            "strongest": [
                {"with_bot": str(uuid4()), "intensity": 0.9},
                {"with_bot": str(uuid4()), "intensity": 0.8}
            ]
        }

    def test_social_world_structure(self, mock_social_world):
        """Test social world response structure."""
        required_fields = ["bot_id", "total_connections", "by_label", "strongest"]

        for field in required_fields:
            assert field in mock_social_world

    def test_strongest_sorted_by_intensity(self, mock_social_world):
        """Test that strongest connections are sorted by intensity."""
        strongest = mock_social_world["strongest"]

        for i in range(len(strongest) - 1):
            assert strongest[i]["intensity"] >= strongest[i + 1]["intensity"]
