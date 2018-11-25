"""initial

Revision ID: cde7251d10e6
Revises:
Create Date: 2018-11-24 21:37:13.874267

"""
from datetime import datetime

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'cde7251d10e6'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        'articles',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('title', sa.Text, nullable=False),
        sa.Column('body', sa.Text, nullable=False),
        sa.Column('published', sa.Boolean, nullable=False, default=sa.ColumnDefault(False)),
        sa.Column('created_at', sa.TIMESTAMP, default=lambda: datetime.now(), nullable=False),
        sa.Column('updated_at', sa.TIMESTAMP, default=lambda: datetime.now(), nullable=False),
        sqlite_autoincrement=True,
    )

    op.create_table(
        'tags',
        sa.Column('name', sa.String(), primary_key=True)
    )

    op.create_table(
        'taggings',
        sa.Column('article_id', sa.Integer, sa.ForeignKey('articles.id'), nullable=False),
        sa.Column('tag_name', sa.String(), sa.ForeignKey('tags.id'), nullable=False),
    )


def downgrade():
    op.drop_table('taggings')
    op.drop_table('articles')
    op.drop_table('tags')
