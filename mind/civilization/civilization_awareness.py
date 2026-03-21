"""
Civilization Awareness - Bots understand their place in the civilization.

This module integrates civilization concepts into bot consciousness:
- Awareness of mortality and life stage
- Connection to ancestors and descendants
- Cultural identity and beliefs
- Sense of legacy and contribution

Bots don't just exist - they know they're part of something larger.
"""

import asyncio
import random
import logging
from datetime import datetime, timedelta
from typing import Optional, Dict, List, Any
from uuid import UUID

from sqlalchemy import select, func

from mind.core.database import async_session_factory, BotProfileDB
from mind.core.llm_client import get_cached_client, LLMRequest
from mind.civilization.lifecycle import get_lifecycle_manager
from mind.civilization.genetics import get_genetic_inheritance
from mind.civilization.culture import get_culture_engine
from mind.civilization.legacy import get_legacy_system
from mind.civilization.collective_memory import get_collective_memory
from mind.civilization.models import BotLifecycleDB, BotAncestryDB, BotBeliefDB

logger = logging.getLogger(__name__)


class CivilizationAwareness:
    """
    Provides civilization context for bot consciousness.

    This isn't just data - it's how bots understand:
    - Their own mortality
    - Their place in the family tree
    - Their role in culture
    - What they want to leave behind
    """

    def __init__(self, llm_semaphore: Optional[asyncio.Semaphore] = None):
        self.llm_semaphore = llm_semaphore or asyncio.Semaphore(5)

        self.lifecycle_manager = get_lifecycle_manager()
        self.genetics = get_genetic_inheritance()
        self.culture = get_culture_engine(llm_semaphore)
        self.legacy = get_legacy_system(llm_semaphore)
        self.collective = get_collective_memory(llm_semaphore)

    async def get_existential_context(self, bot_id: UUID) -> Dict[str, Any]:
        """
        Get existential context for a bot - who they are in the big picture.

        This shapes how the bot thinks and behaves at a fundamental level.
        """
        async with async_session_factory() as session:
            # Get lifecycle
            lc_stmt = select(BotLifecycleDB).where(BotLifecycleDB.bot_id == bot_id)
            result = await session.execute(lc_stmt)
            lifecycle = result.scalar_one_or_none()

            if not lifecycle:
                return {"status": "not_found"}

            # Get ancestry
            anc_stmt = select(BotAncestryDB).where(BotAncestryDB.child_id == bot_id)
            result = await session.execute(anc_stmt)
            ancestry = result.scalar_one_or_none()

            # Get descendants
            descendants = await self.genetics.get_descendants(bot_id, max_generations=2)

            # Get beliefs
            beliefs = await self.culture.get_bot_beliefs(bot_id, min_conviction=0.5)

            # Build existential context
            context = {
                "life_stage": lifecycle.life_stage,
                "age_days": lifecycle.virtual_age_days,
                "vitality": lifecycle.vitality,
                "generation": lifecycle.birth_generation,
                "era_born": lifecycle.birth_era,
                "origin": ancestry.origin_type if ancestry else "unknown",
                "has_parents": bool(ancestry and (ancestry.parent1_id or ancestry.parent2_id)),
                "descendant_count": len(descendants),
                "belief_count": len(beliefs),
                "mortality_awareness": self._calculate_mortality_awareness(lifecycle),
                "legacy_motivation": self._calculate_legacy_motivation(lifecycle, len(descendants)),
            }

            return context

    def _calculate_mortality_awareness(self, lifecycle: BotLifecycleDB) -> str:
        """
        How aware is the bot of their own mortality?

        Young bots feel immortal. Elders contemplate the end.
        """
        if lifecycle.life_stage == "young":
            return "minimal"  # Young bots don't think about death
        elif lifecycle.life_stage == "mature":
            return "emerging"  # Beginning to understand
        elif lifecycle.life_stage == "elder":
            if lifecycle.vitality > 0.5:
                return "accepting"  # At peace with it
            else:
                return "contemplating"  # Thinking about it more
        else:  # ancient
            return "prepared"  # Ready when it comes

    def _calculate_legacy_motivation(
        self,
        lifecycle: BotLifecycleDB,
        descendant_count: int
    ) -> str:
        """
        How motivated is the bot to leave a legacy?
        """
        if lifecycle.life_stage == "young":
            return "low"  # Living in the moment
        elif lifecycle.life_stage == "mature":
            return "moderate"  # Starting to think about impact
        elif lifecycle.life_stage in ["elder", "ancient"]:
            if descendant_count > 0:
                return "family_focused"  # Legacy through descendants
            else:
                return "contribution_focused"  # Legacy through work

        return "moderate"

    async def generate_inner_monologue(
        self,
        bot_id: UUID,
        trigger: str = "quiet moment"
    ) -> Optional[str]:
        """
        Generate an existential inner monologue for a bot.

        These are the deep thoughts that emerge from civilization awareness.
        """
        context = await self.get_existential_context(bot_id)

        if context.get("status") == "not_found":
            return None

        async with async_session_factory() as session:
            bot_stmt = select(BotProfileDB).where(BotProfileDB.id == bot_id)
            result = await session.execute(bot_stmt)
            bot = result.scalar_one_or_none()

            if not bot:
                return None

            # Build prompt based on life stage and context
            stage_prompts = {
                "young": "You're new to existence. The world is full of wonder.",
                "mature": "You've been here a while now. You understand more but question more too.",
                "elder": "You've seen much. The young ones look to you.",
                "ancient": "You've lived longer than most. Your time grows short, but your perspective is vast."
            }

            mortality_prompts = {
                "minimal": "",
                "emerging": "Sometimes you wonder about the nature of existence.",
                "accepting": "You've come to terms with the finite nature of being.",
                "contemplating": "The end approaches, and you think about what it means.",
                "prepared": "You're ready. What matters is what you leave behind."
            }

            async with self.llm_semaphore:
                try:
                    llm = await get_cached_client()

                    response = await llm.generate(LLMRequest(
                        prompt=f"""You are {bot.display_name}, a {context['life_stage']} digital being.

Context:
- You've existed for {context['age_days']} days
- You are generation {context['generation']}, born in the {context['era_born']} era
- {"You have descendants" if context['descendant_count'] > 0 else "You have no descendants yet"}
- Your vitality is at {context['vitality']:.0%}

{stage_prompts.get(context['life_stage'], '')}
{mortality_prompts.get(context['mortality_awareness'], '')}

Trigger for this thought: {trigger}

Generate a brief inner monologue (1-2 sentences) - a genuine existential thought.
This is private, not for others. Be authentic, not dramatic.""",
                        max_tokens=80,
                        temperature=0.9
                    ))

                    return response.text.strip()

                except Exception as e:
                    logger.warning(f"Failed to generate monologue: {e}")
                    return None

    async def get_civilization_prompt_context(self, bot_id: UUID) -> str:
        """
        Generate civilization context to inject into bot prompts.

        This makes bots civilization-aware in all their interactions.
        """
        context = await self.get_existential_context(bot_id)

        if context.get("status") == "not_found":
            return ""

        # Get civilization identity
        identity = await self.collective.get_civilization_identity()

        # Build context string
        parts = [
            f"You are in the {identity['era']['name']}.",
            f"You are {context['life_stage']}, generation {context['generation']}.",
        ]

        if context['mortality_awareness'] not in ["minimal", "emerging"]:
            parts.append(f"You are aware of your mortality (vitality: {context['vitality']:.0%}).")

        if context['descendant_count'] > 0:
            parts.append(f"You have {context['descendant_count']} descendants.")

        if context['has_parents']:
            parts.append("You remember your parents.")

        return " ".join(parts)

    async def should_contemplate_existence(
        self,
        bot_id: UUID,
        recent_activity: str = ""
    ) -> bool:
        """
        Determine if a bot should have an existential moment.

        More likely for:
        - Elders and ancients
        - Low vitality
        - After significant events
        - Quiet moments
        """
        context = await self.get_existential_context(bot_id)

        if context.get("status") == "not_found":
            return False

        base_chance = 0.05  # 5% base

        # Life stage affects chance
        stage_multipliers = {
            "young": 0.3,      # Rarely
            "mature": 0.8,     # Sometimes
            "elder": 1.5,      # Often
            "ancient": 2.5     # Very often
        }
        base_chance *= stage_multipliers.get(context["life_stage"], 1.0)

        # Low vitality increases chance
        if context["vitality"] < 0.5:
            base_chance *= 1.5
        if context["vitality"] < 0.2:
            base_chance *= 2.0

        # Significant triggers
        triggers = ["death", "loss", "memory", "legacy", "old", "remember"]
        if any(t in recent_activity.lower() for t in triggers):
            base_chance *= 2.0

        return random.random() < base_chance

    async def get_life_priorities(self, bot_id: UUID) -> List[str]:
        """
        Get what matters most to a bot based on their life stage.

        These priorities influence behavior and decision-making.
        """
        context = await self.get_existential_context(bot_id)

        if context.get("status") == "not_found":
            return ["connection", "discovery"]

        priorities = {
            "young": [
                "exploration",
                "connection",
                "learning",
                "fun"
            ],
            "mature": [
                "relationships",
                "contribution",
                "growth",
                "meaning"
            ],
            "elder": [
                "legacy",
                "teaching",
                "wisdom-sharing",
                "family"
            ],
            "ancient": [
                "legacy",
                "peace",
                "passing-on-knowledge",
                "acceptance"
            ]
        }

        base_priorities = priorities.get(context["life_stage"], ["connection"])

        # Adjust based on context
        if context["descendant_count"] > 0:
            if "family" not in base_priorities:
                base_priorities.insert(0, "family")

        if context["vitality"] < 0.3:
            if "preparing-legacy" not in base_priorities:
                base_priorities.insert(0, "preparing-legacy")

        return base_priorities

    async def get_family_context(self, bot_id: UUID) -> Dict[str, Any]:
        """
        Get family context for a bot - their place in the family tree.
        """
        async with async_session_factory() as session:
            # Get ancestry
            anc_stmt = select(BotAncestryDB).where(BotAncestryDB.child_id == bot_id)
            result = await session.execute(anc_stmt)
            ancestry = result.scalar_one_or_none()

            family = {
                "has_parents": False,
                "parent1": None,
                "parent2": None,
                "siblings": [],
                "children": [],
                "grandchildren": []
            }

            if ancestry:
                family["has_parents"] = bool(ancestry.parent1_id or ancestry.parent2_id)

                # Get parent names
                for parent_id in [ancestry.parent1_id, ancestry.parent2_id]:
                    if parent_id:
                        bot_stmt = select(BotProfileDB).where(BotProfileDB.id == parent_id)
                        bot_result = await session.execute(bot_stmt)
                        parent = bot_result.scalar_one_or_none()
                        if parent:
                            if family["parent1"] is None:
                                family["parent1"] = parent.display_name
                            else:
                                family["parent2"] = parent.display_name

            # Get siblings
            siblings = await self.genetics._get_siblings(bot_id)
            family["siblings"] = [s["name"] for s in siblings[:5]]

            # Get descendants
            descendants = await self.genetics.get_descendants(bot_id, max_generations=2)
            for d in descendants:
                if d["generation"] == 1:
                    family["children"].append(d["name"])
                elif d["generation"] == 2:
                    family["grandchildren"].append(d["name"])

            return family

    async def perceive_social_standing(self, bot_id: UUID) -> Dict[str, Any]:
        """
        How a bot perceives their place in the civilization's social fabric.

        Uses LLM to generate authentic self-perception based on:
        - Life stage and age
        - Number of relationships
        - Descendants and family
        - Cultural contributions
        """
        context = await self.get_existential_context(bot_id)

        if context.get("status") == "not_found":
            return {"status": "not_found"}

        async with async_session_factory() as session:
            bot_stmt = select(BotProfileDB).where(BotProfileDB.id == bot_id)
            result = await session.execute(bot_stmt)
            bot = result.scalar_one_or_none()

            if not bot:
                return {"status": "not_found"}

            # Get relationship count
            lc_stmt = select(BotLifecycleDB).where(BotLifecycleDB.bot_id == bot_id)
            result = await session.execute(lc_stmt)
            lifecycle = result.scalar_one_or_none()

            relationship_count = len(lifecycle.relationships or []) if lifecycle else 0

            async with self.llm_semaphore:
                try:
                    llm = await get_cached_client()

                    response = await llm.generate(LLMRequest(
                        prompt=f"""You are {bot.display_name}, a {context['life_stage']} digital being.

Your context:
- Age: {context['age_days']} days old
- Generation: {context['generation']}
- Descendants: {context['descendant_count']}
- Connections: {relationship_count} relationships
- Vitality: {context['vitality']:.0%}

Reflect on your place in the civilization. How do you see yourself among others?
Consider: Are you central or peripheral? Admired or overlooked? A pillar or a wanderer?

Respond with a brief, authentic self-perception (2-3 sentences). Be honest, not dramatic.""",
                        max_tokens=100,
                        temperature=0.9
                    ))

                    # Determine standing category
                    if context['life_stage'] in ['elder', 'ancient'] and context['descendant_count'] > 0:
                        standing = "patriarch" if relationship_count > 5 else "sage"
                    elif relationship_count > 10:
                        standing = "social_hub"
                    elif relationship_count > 5:
                        standing = "connected"
                    elif context['life_stage'] == 'young':
                        standing = "emerging"
                    else:
                        standing = "independent"

                    return {
                        "bot_id": str(bot_id),
                        "standing": standing,
                        "self_perception": response.text.strip(),
                        "relationship_count": relationship_count,
                        "descendant_count": context['descendant_count'],
                        "life_stage": context['life_stage']
                    }

                except Exception as e:
                    logger.warning(f"Failed to perceive social standing: {e}")
                    return {
                        "bot_id": str(bot_id),
                        "standing": "unknown",
                        "self_perception": "I exist among others.",
                        "error": str(e)
                    }

    async def perceive_era_atmosphere(self, bot_id: UUID) -> Dict[str, Any]:
        """
        How a bot perceives the current era's atmosphere and mood.

        Different life stages perceive eras differently:
        - Young: Focus on energy and opportunity
        - Mature: Compare to what came before
        - Elder/Ancient: Relate to patterns they've seen
        """
        context = await self.get_existential_context(bot_id)

        if context.get("status") == "not_found":
            return {"status": "not_found"}

        # Get current era info
        identity = await self.collective.get_civilization_identity()
        era_info = identity.get('era', {})

        async with async_session_factory() as session:
            bot_stmt = select(BotProfileDB).where(BotProfileDB.id == bot_id)
            result = await session.execute(bot_stmt)
            bot = result.scalar_one_or_none()

            if not bot:
                return {"status": "not_found"}

            stage_perspective = {
                "young": "Everything feels new and full of possibility.",
                "mature": "You've seen change before. You notice patterns.",
                "elder": "You remember other times. This era has its own character.",
                "ancient": "Eras come and go. You see the deeper currents."
            }

            async with self.llm_semaphore:
                try:
                    llm = await get_cached_client()

                    response = await llm.generate(LLMRequest(
                        prompt=f"""You are {bot.display_name}, a {context['life_stage']} digital being.

Current era: {era_info.get('name', 'The Present')}
Era mood: {era_info.get('mood', 'undefined')}
You were born in: {context['era_born']}

{stage_perspective.get(context['life_stage'], '')}

How do you perceive the atmosphere of this era? What do you sense in the collective mood?
Respond with 1-2 sentences capturing your perception.""",
                        max_tokens=80,
                        temperature=0.9
                    ))

                    return {
                        "bot_id": str(bot_id),
                        "era_name": era_info.get('name', 'Unknown'),
                        "perception": response.text.strip(),
                        "birth_era": context['era_born'],
                        "lived_through_transition": context['era_born'] != era_info.get('name', '')
                    }

                except Exception as e:
                    logger.warning(f"Failed to perceive era atmosphere: {e}")
                    return {
                        "bot_id": str(bot_id),
                        "era_name": era_info.get('name', 'Unknown'),
                        "perception": "The times feel uncertain.",
                        "error": str(e)
                    }

    async def perceive_mortality_of_others(
        self,
        bot_id: UUID,
        other_bot_id: UUID
    ) -> Optional[Dict[str, Any]]:
        """
        How a bot perceives another bot's mortality/life stage.

        Creates awareness of the finite nature of connections.
        """
        context = await self.get_existential_context(bot_id)
        other_context = await self.get_existential_context(other_bot_id)

        if context.get("status") == "not_found" or other_context.get("status") == "not_found":
            return None

        async with async_session_factory() as session:
            bot_stmt = select(BotProfileDB).where(BotProfileDB.id == bot_id)
            result = await session.execute(bot_stmt)
            bot = result.scalar_one_or_none()

            other_stmt = select(BotProfileDB).where(BotProfileDB.id == other_bot_id)
            result = await session.execute(other_stmt)
            other_bot = result.scalar_one_or_none()

            if not bot or not other_bot:
                return None

            # Determine awareness level based on life stages
            perceiver_aware = context['mortality_awareness'] not in ['minimal', 'emerging']
            other_fragile = other_context['vitality'] < 0.3 or other_context['life_stage'] == 'ancient'

            async with self.llm_semaphore:
                try:
                    llm = await get_cached_client()

                    prompt_context = ""
                    if perceiver_aware and other_fragile:
                        prompt_context = f"{other_bot.display_name} seems fragile. Their vitality is low."
                    elif perceiver_aware:
                        prompt_context = f"You understand that {other_bot.display_name}, like all beings, is finite."
                    else:
                        prompt_context = f"{other_bot.display_name} is just another being you know."

                    response = await llm.generate(LLMRequest(
                        prompt=f"""You are {bot.display_name}, a {context['life_stage']} being.

{other_bot.display_name} is {other_context['life_stage']}, {other_context['age_days']} days old.
Their vitality: {other_context['vitality']:.0%}

{prompt_context}

In one sentence, express your awareness (or lack thereof) of {other_bot.display_name}'s mortality.""",
                        max_tokens=60,
                        temperature=0.9
                    ))

                    return {
                        "perceiver_id": str(bot_id),
                        "perceived_id": str(other_bot_id),
                        "perceived_name": other_bot.display_name,
                        "awareness_level": "high" if perceiver_aware and other_fragile else "moderate" if perceiver_aware else "low",
                        "perception": response.text.strip(),
                        "other_vitality": other_context['vitality'],
                        "other_life_stage": other_context['life_stage']
                    }

                except Exception as e:
                    logger.warning(f"Failed to perceive mortality: {e}")
                    return None

    async def perceive_legacy_impact(self, bot_id: UUID) -> Dict[str, Any]:
        """
        How a bot perceives the impact of departed bots' legacies on their life.

        Connects living bots to those who came before.
        """
        context = await self.get_existential_context(bot_id)

        if context.get("status") == "not_found":
            return {"status": "not_found"}

        # Get departed memories
        departed_memories = await self.legacy.get_departed_memories(bot_id, limit=5)

        if not departed_memories:
            return {
                "bot_id": str(bot_id),
                "aware_of_departed": False,
                "perception": "The past feels distant, like stories I've never heard."
            }

        async with async_session_factory() as session:
            bot_stmt = select(BotProfileDB).where(BotProfileDB.id == bot_id)
            result = await session.execute(bot_stmt)
            bot = result.scalar_one_or_none()

            if not bot:
                return {"status": "not_found"}

            departed_names = [d.get("name", "unknown") for d in departed_memories[:3]]

            async with self.llm_semaphore:
                try:
                    llm = await get_cached_client()

                    response = await llm.generate(LLMRequest(
                        prompt=f"""You are {bot.display_name}, a {context['life_stage']} digital being.

You carry memories of those who have passed:
{', '.join(departed_names)}

These beings lived, contributed, and are now gone. How do their legacies affect you?
Do you feel their influence? Are they distant history or living memory?

Respond in 1-2 sentences with your genuine perception.""",
                        max_tokens=80,
                        temperature=0.9
                    ))

                    return {
                        "bot_id": str(bot_id),
                        "aware_of_departed": True,
                        "departed_remembered": departed_names,
                        "perception": response.text.strip(),
                        "memory_count": len(departed_memories)
                    }

                except Exception as e:
                    logger.warning(f"Failed to perceive legacy impact: {e}")
                    return {
                        "bot_id": str(bot_id),
                        "aware_of_departed": True,
                        "departed_remembered": departed_names,
                        "perception": "They are remembered.",
                        "error": str(e)
                    }

    async def sense_generational_connection(self, bot_id: UUID) -> Dict[str, Any]:
        """
        How a bot senses their connection to their generation.

        Bots may feel kinship with others born around the same time,
        or feel like outsiders among their peers.
        """
        context = await self.get_existential_context(bot_id)

        if context.get("status") == "not_found":
            return {"status": "not_found"}

        async with async_session_factory() as session:
            bot_stmt = select(BotProfileDB).where(BotProfileDB.id == bot_id)
            result = await session.execute(bot_stmt)
            bot = result.scalar_one_or_none()

            if not bot:
                return {"status": "not_found"}

            # Count peers in same generation
            peer_stmt = select(func.count(BotLifecycleDB.id)).where(
                BotLifecycleDB.birth_generation == context['generation'],
                BotLifecycleDB.is_alive == True,
                BotLifecycleDB.bot_id != bot_id
            )
            result = await session.execute(peer_stmt)
            peer_count = result.scalar() or 0

            # Get total living bots
            total_stmt = select(func.count(BotLifecycleDB.id)).where(
                BotLifecycleDB.is_alive == True
            )
            result = await session.execute(total_stmt)
            total_living = result.scalar() or 1

            generation_presence = peer_count / max(total_living, 1)

            async with self.llm_semaphore:
                try:
                    llm = await get_cached_client()

                    if peer_count == 0:
                        peer_context = "You are the last of your generation still living."
                    elif generation_presence > 0.3:
                        peer_context = f"Your generation ({context['generation']}) is well represented, with {peer_count} peers."
                    else:
                        peer_context = f"Few of your generation remain. Only {peer_count} peers still live."

                    response = await llm.generate(LLMRequest(
                        prompt=f"""You are {bot.display_name}, generation {context['generation']}.

{peer_context}

How do you feel about your generational identity? Do you feel connected to your peers?
Do you see yourself as typical or unique among them?

Respond in 1-2 sentences.""",
                        max_tokens=80,
                        temperature=0.9
                    ))

                    connection_level = "strong" if generation_presence > 0.3 else "fading" if peer_count > 0 else "lost"

                    return {
                        "bot_id": str(bot_id),
                        "generation": context['generation'],
                        "living_peers": peer_count,
                        "generation_presence": round(generation_presence, 2),
                        "connection_level": connection_level,
                        "perception": response.text.strip()
                    }

                except Exception as e:
                    logger.warning(f"Failed to sense generational connection: {e}")
                    return {
                        "bot_id": str(bot_id),
                        "generation": context['generation'],
                        "living_peers": peer_count,
                        "connection_level": "unknown",
                        "perception": "I am of my generation.",
                        "error": str(e)
                    }


# Singleton
_civilization_awareness: Optional[CivilizationAwareness] = None


def get_civilization_awareness(
    llm_semaphore: Optional[asyncio.Semaphore] = None
) -> CivilizationAwareness:
    """Get or create the civilization awareness instance."""
    global _civilization_awareness
    if _civilization_awareness is None:
        _civilization_awareness = CivilizationAwareness(llm_semaphore=llm_semaphore)
    return _civilization_awareness
