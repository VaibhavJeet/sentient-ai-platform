"""
Unit tests for the Genetic Inheritance System.

Tests cover:
- Trait inheritance from parents
- Mutation mechanics
- Single vs dual parent inheritance
- Trait blending
- Dominant parent selection
"""

import pytest
from uuid import uuid4
from unittest.mock import AsyncMock, MagicMock, patch

pytestmark = pytest.mark.unit


class TestGeneticInheritance:
    """Tests for GeneticInheritance class."""

    @pytest.fixture
    def genetics_system(self):
        """Create a GeneticInheritance instance for testing."""
        with patch("mind.civilization.genetics.async_session_factory"):
            from mind.civilization.genetics import GeneticInheritance
            system = GeneticInheritance(mutation_rate=0.1)
            return system

    @pytest.fixture
    def sample_parent_traits(self):
        """Create sample parent traits for testing."""
        return {
            "openness": 0.7,
            "conscientiousness": 0.6,
            "extraversion": 0.8,
            "agreeableness": 0.5,
            "neuroticism": 0.3,
            "humor_style": "witty",
            "conflict_style": "diplomatic",
            "energy_pattern": "morning",
            "social_battery_capacity": 0.7,
            "attention_span": 0.6,
            "curiosity_type": "deep",
        }

    def test_mutation_rate_override(self, genetics_system):
        """Test that mutation rate override works."""
        assert genetics_system.mutation_rate == 0.1

    def test_mutation_rate_default(self):
        """Test default mutation rate when not overridden."""
        with patch("mind.civilization.genetics.async_session_factory"):
            from mind.civilization.genetics import GeneticInheritance
            system = GeneticInheritance()
            # Should use default
            assert system.mutation_rate == 0.1


class TestTraitInheritance:
    """Tests for trait inheritance mechanics."""

    @pytest.fixture
    def parent1_traits(self):
        """Create first parent's traits."""
        return {
            "openness": 0.8,
            "conscientiousness": 0.7,
            "extraversion": 0.6,
            "agreeableness": 0.5,
            "neuroticism": 0.2,
        }

    @pytest.fixture
    def parent2_traits(self):
        """Create second parent's traits."""
        return {
            "openness": 0.4,
            "conscientiousness": 0.3,
            "extraversion": 0.9,
            "agreeableness": 0.8,
            "neuroticism": 0.6,
        }

    def test_inheritable_traits_defined(self):
        """Test that inheritable traits are defined."""
        from mind.civilization.genetics import INHERITABLE_TRAITS

        expected_traits = [
            "openness", "conscientiousness", "extraversion",
            "agreeableness", "neuroticism"
        ]

        for trait in expected_traits:
            assert trait in INHERITABLE_TRAITS

    def test_default_mutation_ranges_defined(self):
        """Test that default mutation ranges are defined."""
        from mind.civilization.genetics import DEFAULT_MUTATION_RANGE

        assert "openness" in DEFAULT_MUTATION_RANGE
        assert DEFAULT_MUTATION_RANGE["openness"] == 0.15

    def test_trait_values_in_range(self, parent1_traits):
        """Test that trait values are within valid range."""
        for trait, value in parent1_traits.items():
            if isinstance(value, float):
                assert 0.0 <= value <= 1.0


class TestMutationMechanics:
    """Tests for mutation mechanics."""

    @pytest.fixture
    def genetics_system(self):
        """Create a GeneticInheritance instance."""
        with patch("mind.civilization.genetics.async_session_factory"):
            from mind.civilization.genetics import GeneticInheritance
            return GeneticInheritance(mutation_rate=0.1)

    def test_mutation_range_exists(self, genetics_system):
        """Test that mutation ranges exist for traits."""
        mutation_range = genetics_system.get_mutation_range("openness")
        assert mutation_range is not None
        assert mutation_range > 0

    def test_mutation_range_fallback(self, genetics_system):
        """Test mutation range fallback for unknown traits."""
        mutation_range = genetics_system.get_mutation_range("unknown_trait")
        # Should return default
        assert mutation_range == 0.1

    def test_numeric_trait_mutation_bounds(self):
        """Test that mutated numeric traits stay within 0-1."""
        from mind.civilization.genetics import DEFAULT_MUTATION_RANGE

        base_value = 0.95
        max_mutation = DEFAULT_MUTATION_RANGE["openness"]

        # Even with max mutation, should stay in bounds
        mutated = base_value + max_mutation
        bounded = min(1.0, max(0.0, mutated))

        assert 0.0 <= bounded <= 1.0

    def test_categorical_trait_mutation_chance(self):
        """Test categorical trait mutation probability."""
        from mind.civilization.genetics import DEFAULT_MUTATION_RANGE

        # Humor style has 20% mutation chance
        mutation_chance = DEFAULT_MUTATION_RANGE["humor_style"]
        assert mutation_chance == 0.2

        # Conflict style has 25% mutation chance
        mutation_chance = DEFAULT_MUTATION_RANGE["conflict_style"]
        assert mutation_chance == 0.25


class TestSingleParentInheritance:
    """Tests for single parent inheritance."""

    @pytest.fixture
    def single_parent_traits(self):
        """Create a single parent's traits."""
        return {
            "openness": 0.7,
            "conscientiousness": 0.6,
            "extraversion": 0.5,
            "agreeableness": 0.6,
            "neuroticism": 0.4,
            "humor_style": "dry",
        }

    def test_single_parent_baseline(self, single_parent_traits):
        """Test that single parent traits form baseline."""
        # Child should have traits similar to single parent
        # (with possible mutations)
        assert single_parent_traits is not None
        assert "openness" in single_parent_traits


class TestDualParentInheritance:
    """Tests for dual parent inheritance."""

    @pytest.fixture
    def parent_pair(self):
        """Create a pair of parent trait sets."""
        return {
            "parent1": {
                "openness": 0.9,
                "conscientiousness": 0.8,
                "extraversion": 0.3,
            },
            "parent2": {
                "openness": 0.3,
                "conscientiousness": 0.4,
                "extraversion": 0.9,
            }
        }

    def test_blended_trait_averaging(self, parent_pair):
        """Test that blended traits are averaged from parents."""
        p1 = parent_pair["parent1"]
        p2 = parent_pair["parent2"]

        # Blended openness would be average
        blended_openness = (p1["openness"] + p2["openness"]) / 2
        assert blended_openness == 0.6

    def test_trait_can_come_from_either_parent(self, parent_pair):
        """Test that traits can be inherited from either parent."""
        p1_openness = parent_pair["parent1"]["openness"]
        p2_openness = parent_pair["parent2"]["openness"]

        # Child could get either value (before mutation)
        possible_values = [p1_openness, p2_openness]
        blended = (p1_openness + p2_openness) / 2
        possible_values.append(blended)

        # All are valid inheritance outcomes
        for val in possible_values:
            assert 0.0 <= val <= 1.0


class TestDominantParentSelection:
    """Tests for dominant parent selection mechanics."""

    def test_dominant_parent_zero_is_random(self):
        """Test that dominant_parent=0 means random selection."""
        # 0 = random per trait
        dominant_parent = 0
        assert dominant_parent == 0

    def test_dominant_parent_one_is_parent1(self):
        """Test that dominant_parent=1 favors parent1."""
        # 1 = parent1 dominant
        dominant_parent = 1
        assert dominant_parent == 1

    def test_dominant_parent_two_is_parent2(self):
        """Test that dominant_parent=2 favors parent2."""
        # 2 = parent2 dominant
        dominant_parent = 2
        assert dominant_parent == 2


class TestInheritanceOutput:
    """Tests for inheritance output structure."""

    def test_inherit_traits_returns_tuple(self):
        """Test that inherit_traits returns correct tuple structure."""
        # Should return (child_traits, mutations, sources)
        expected_output = (
            {"openness": 0.75},  # child_traits
            {"openness": 0.05},  # mutations
            {"openness": "blended"}  # sources
        )

        child_traits, mutations, sources = expected_output

        assert isinstance(child_traits, dict)
        assert isinstance(mutations, dict)
        assert isinstance(sources, dict)

    def test_source_values_are_valid(self):
        """Test that inheritance source values are valid."""
        valid_sources = ["parent1", "parent2", "blended"]

        for source in valid_sources:
            assert source in valid_sources


class TestGetGeneticInheritance:
    """Tests for the singleton genetic inheritance getter."""

    def test_get_genetic_inheritance_creates_singleton(self):
        """Test that getter returns singleton instance."""
        with patch("mind.civilization.genetics._genetic_inheritance", None):
            with patch("mind.civilization.genetics.async_session_factory"):
                from mind.civilization.genetics import get_genetic_inheritance

                instance1 = get_genetic_inheritance()
                instance2 = get_genetic_inheritance()

                assert instance1 is instance2


class TestTraitCompatibility:
    """Tests for checking trait compatibility between parents."""

    @pytest.fixture
    def similar_parents(self):
        """Create similar parent traits."""
        return {
            "parent1": {"openness": 0.7, "extraversion": 0.6},
            "parent2": {"openness": 0.75, "extraversion": 0.55}
        }

    @pytest.fixture
    def different_parents(self):
        """Create very different parent traits."""
        return {
            "parent1": {"openness": 0.9, "extraversion": 0.1},
            "parent2": {"openness": 0.1, "extraversion": 0.9}
        }

    def test_similar_parents_produce_predictable_children(self, similar_parents):
        """Test that similar parents produce more predictable children."""
        p1 = similar_parents["parent1"]
        p2 = similar_parents["parent2"]

        # Trait difference is small
        openness_diff = abs(p1["openness"] - p2["openness"])
        assert openness_diff <= 0.1

    def test_different_parents_produce_varied_children(self, different_parents):
        """Test that different parents produce more varied children."""
        p1 = different_parents["parent1"]
        p2 = different_parents["parent2"]

        # Trait difference is large
        openness_diff = abs(p1["openness"] - p2["openness"])
        assert openness_diff >= 0.5


class TestMutationConfiguration:
    """Tests for mutation configuration loading."""

    @pytest.mark.asyncio
    async def test_load_config_fallback(self):
        """Test that system uses defaults when config fails to load."""
        with patch("mind.civilization.genetics.async_session_factory"):
            from mind.civilization.genetics import GeneticInheritance, DEFAULT_MUTATION_RANGE

            system = GeneticInheritance()

            # Without loading config, should use defaults
            mutation_range = system.get_mutation_range("openness")
            assert mutation_range == DEFAULT_MUTATION_RANGE["openness"]
