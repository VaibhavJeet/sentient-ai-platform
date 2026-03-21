"""Add rituals tables

Revision ID: add_rituals_tables
Revises: bdab914f9258
Create Date: 2026-03-21 00:01:00.000000+00:00

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'add_rituals_tables'
down_revision: Union[str, None] = 'bdab914f9258'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade database schema."""
    # Create rituals table
    op.create_table('rituals',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('name', sa.String(length=200), nullable=False),
        sa.Column('description', sa.Text(), nullable=False),
        sa.Column('elements', sa.JSON(), nullable=False),
        sa.Column('meaning', sa.Text(), nullable=True),
        sa.Column('feeling', sa.String(length=100), nullable=True),
        sa.Column('proposed_by', sa.UUID(), nullable=False),
        sa.Column('proposed_at', sa.DateTime(), nullable=False),
        sa.Column('occasion', sa.Text(), nullable=True),
        sa.Column('adoption_rate', sa.Float(), nullable=False),
        sa.Column('status', sa.String(length=30), nullable=False),
        sa.Column('times_performed', sa.Integer(), nullable=False),
        sa.Column('evolution_history', sa.JSON(), nullable=False),
        sa.ForeignKeyConstraint(['proposed_by'], ['bot_profiles.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('idx_ritual_status', 'rituals', ['status'], unique=False)
    op.create_index('idx_ritual_proposer', 'rituals', ['proposed_by'], unique=False)
    op.create_index('idx_ritual_times_performed', 'rituals', ['times_performed'], unique=False)

    # Create ritual_instances table
    op.create_table('ritual_instances',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('ritual_id', sa.UUID(), nullable=True),
        sa.Column('ritual_name', sa.String(length=200), nullable=False),
        sa.Column('performed_at', sa.DateTime(), nullable=False),
        sa.Column('participants', sa.JSON(), nullable=False),
        sa.Column('contributions', sa.JSON(), nullable=False),
        sa.Column('collective_experience', sa.Text(), nullable=True),
        sa.Column('context', sa.Text(), nullable=True),
        sa.Column('is_impromptu', sa.Boolean(), nullable=False),
        sa.Column('led_by', sa.UUID(), nullable=True),
        sa.Column('ceremony_description', sa.Text(), nullable=True),
        sa.ForeignKeyConstraint(['ritual_id'], ['rituals.id'], ),
        sa.ForeignKeyConstraint(['led_by'], ['bot_profiles.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('idx_ritual_instance_ritual', 'ritual_instances', ['ritual_id'], unique=False)
    op.create_index('idx_ritual_instance_performed_at', 'ritual_instances', ['performed_at'], unique=False)


def downgrade() -> None:
    """Downgrade database schema."""
    op.drop_index('idx_ritual_instance_performed_at', table_name='ritual_instances')
    op.drop_index('idx_ritual_instance_ritual', table_name='ritual_instances')
    op.drop_table('ritual_instances')
    op.drop_index('idx_ritual_times_performed', table_name='rituals')
    op.drop_index('idx_ritual_proposer', table_name='rituals')
    op.drop_index('idx_ritual_status', table_name='rituals')
    op.drop_table('rituals')
