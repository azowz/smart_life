from sqlalchemy import Column, Integer, DateTime, ForeignKey, PrimaryKeyConstraint, Index
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from final_project.db import Base

# SQLAlchemy model for the many-to-many association between tasks and categories
class TaskCategoryDB(Base):
    __tablename__ = "task_category"

    task_id = Column(Integer, ForeignKey("tasks.task_id", ondelete="CASCADE"), primary_key=True)  # Link to TaskDB
    category_id = Column(Integer, ForeignKey("category.category_id", ondelete="CASCADE"), primary_key=True)  # Link to CategoryDB
    created_at = Column(DateTime, server_default=func.now())  # Creation timestamp
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())  # Last updated timestamp

    __table_args__ = (
        PrimaryKeyConstraint('task_id', 'category_id'),  # Composite primary key
        Index("idx_task_category_task_id", "task_id"),  # Index on task_id
        Index("idx_task_category_category_id", "category_id"),  # Index on category_id
    )

    # Relationships (optional, add if needed)
    task = relationship(
    "TaskDB",
    back_populates="task_categories",
    overlaps="categories"
)

    category = relationship(
    "CategoryDB",
    back_populates="task_categories",
    overlaps="tasks"
)
