"""Initial migration

Revision ID: 001_initial
Revises: 
Create Date: 2024-01-01 00:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '001_initial'
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create leak_checks table
    op.create_table(
        'leak_checks',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('reading_a', sa.Float(), nullable=False),
        sa.Column('reading_b', sa.Float(), nullable=False),
        sa.Column('no_water_used', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('delta', sa.Float(), nullable=False),
        sa.Column('leak_detected', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('confidence', sa.String(length=50), nullable=False),
        sa.Column('photo_path_a', sa.String(length=500), nullable=True),
        sa.Column('photo_path_b', sa.String(length=500), nullable=True),
        sa.Column('duration_minutes', sa.Integer(), nullable=False, server_default='10'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_leak_checks_id'), 'leak_checks', ['id'], unique=False)

    # Create bill_analyses table
    op.create_table(
        'bill_analyses',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('period_start', sa.DateTime(timezone=True), nullable=False),
        sa.Column('period_end', sa.DateTime(timezone=True), nullable=False),
        sa.Column('usage', sa.Float(), nullable=False),
        sa.Column('amount', sa.Float(), nullable=False),
        sa.Column('photo_path', sa.String(length=500), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_bill_analyses_id'), 'bill_analyses', ['id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_bill_analyses_id'), table_name='bill_analyses')
    op.drop_table('bill_analyses')
    op.drop_index(op.f('ix_leak_checks_id'), table_name='leak_checks')
    op.drop_table('leak_checks')


