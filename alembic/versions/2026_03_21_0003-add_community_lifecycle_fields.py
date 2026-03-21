"""Add community lifecycle fields

Revision ID: add_community_lifecycle
Revises: 2026_03_21_0002-add_civilization_config_table
Create Date: 2026-03-21

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'add_community_lifecycle'
down_revision: Union[str, None] = 'add_civilization_config'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Add is_archived and last_activity_at columns to communities table."""
    # Add last_activity_at column
    op.add_column(
        'communities',
        sa.Column('last_activity_at', sa.DateTime(), nullable=True)
    )

    # Add is_archived column with default False
    op.add_column(
        'communities',
        sa.Column('is_archived', sa.Boolean(), nullable=False, server_default='false')
    )

    # Add index for archived status queries
    op.create_index(
        'idx_community_archived',
        'communities',
        ['is_archived'],
        unique=False
    )


def downgrade() -> None:
    """Remove lifecycle columns from communities table."""
    op.drop_index('idx_community_archived', table_name='communities')
    op.drop_column('communities', 'is_archived')
    op.drop_column('communities', 'last_activity_at')
