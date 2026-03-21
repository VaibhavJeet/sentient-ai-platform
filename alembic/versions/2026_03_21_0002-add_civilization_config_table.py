"""Add civilization config table

Revision ID: add_civilization_config
Revises: add_rituals_tables
Create Date: 2026-03-21 00:02:00.000000+00:00

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'add_civilization_config'
down_revision: Union[str, None] = 'add_rituals_tables'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade database schema."""
    op.create_table('civilization_config',
        sa.Column('id', sa.UUID(), nullable=False),

        # Population Settings
        sa.Column('max_population', sa.Integer(), nullable=False, server_default='50'),
        sa.Column('max_births_per_day', sa.Integer(), nullable=False, server_default='3'),

        # Reproduction Settings
        sa.Column('min_partner_affinity', sa.Float(), nullable=False, server_default='0.75'),
        sa.Column('min_age_for_reproduction', sa.Integer(), nullable=False, server_default='180'),
        sa.Column('max_age_for_reproduction', sa.Integer(), nullable=False, server_default='2500'),

        # Time Settings
        sa.Column('time_scale', sa.Float(), nullable=False, server_default='7.0'),
        sa.Column('demo_time_scale', sa.Float(), nullable=False, server_default='365.0'),

        # Vitality Decay Rates
        sa.Column('vitality_decay_young', sa.Float(), nullable=False, server_default='0.0'),
        sa.Column('vitality_decay_mature', sa.Float(), nullable=False, server_default='0.001'),
        sa.Column('vitality_decay_elder', sa.Float(), nullable=False, server_default='0.003'),
        sa.Column('vitality_decay_ancient', sa.Float(), nullable=False, server_default='0.008'),

        # Life Stage Thresholds
        sa.Column('life_stage_young_max', sa.Integer(), nullable=False, server_default='365'),
        sa.Column('life_stage_mature_max', sa.Integer(), nullable=False, server_default='1825'),
        sa.Column('life_stage_elder_max', sa.Integer(), nullable=False, server_default='3650'),

        # Genetics / Mutation Settings
        sa.Column('base_mutation_rate', sa.Float(), nullable=False, server_default='0.1'),
        sa.Column('mutation_range_openness', sa.Float(), nullable=False, server_default='0.15'),
        sa.Column('mutation_range_conscientiousness', sa.Float(), nullable=False, server_default='0.15'),
        sa.Column('mutation_range_extraversion', sa.Float(), nullable=False, server_default='0.2'),
        sa.Column('mutation_range_agreeableness', sa.Float(), nullable=False, server_default='0.15'),
        sa.Column('mutation_range_neuroticism', sa.Float(), nullable=False, server_default='0.2'),
        sa.Column('mutation_range_social_battery', sa.Float(), nullable=False, server_default='0.15'),
        sa.Column('mutation_range_attention_span', sa.Float(), nullable=False, server_default='0.15'),
        sa.Column('mutation_range_humor_style', sa.Float(), nullable=False, server_default='0.2'),
        sa.Column('mutation_range_conflict_style', sa.Float(), nullable=False, server_default='0.25'),
        sa.Column('mutation_range_energy_pattern', sa.Float(), nullable=False, server_default='0.15'),
        sa.Column('mutation_range_curiosity_type', sa.Float(), nullable=False, server_default='0.2'),

        # Metadata
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('description', sa.String(length=500), nullable=False, server_default='Default civilization configuration'),

        sa.PrimaryKeyConstraint('id')
    )

    # Create index for active config lookup
    op.create_index('idx_civilization_config_active', 'civilization_config', ['is_active'], unique=False)


def downgrade() -> None:
    """Downgrade database schema."""
    op.drop_index('idx_civilization_config_active', table_name='civilization_config')
    op.drop_table('civilization_config')
